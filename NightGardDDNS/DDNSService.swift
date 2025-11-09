//
//  DDNSService.swift
//  NightGardDDNS
//
//  DDNS update service supporting DuckDNS
//  Extracted from wWw NGPortal 2025-11-09
//

import Foundation
import Network

@MainActor
@Observable
public class DDNSService {
    private var updateTimer: Timer?
    public var isRunning = false
    public var lastUpdateTime: Date?
    public var lastStatus: String = "Idle"
    public var currentIP: String?
    public var localIP: String?

    public var domain: String = "" {
        didSet {
            UserDefaults.standard.set(domain, forKey: "ddns_domain")
        }
    }

    public var token: String = "" {
        didSet {
            UserDefaults.standard.set(token, forKey: "ddns_token")
        }
    }

    public var updateInterval: TimeInterval = 300 {
        didSet {
            UserDefaults.standard.set(updateInterval, forKey: "ddns_interval")
        }
    }

    public init() {
        // Load saved settings
        domain = UserDefaults.standard.string(forKey: "ddns_domain") ?? ""
        token = UserDefaults.standard.string(forKey: "ddns_token") ?? ""
        updateInterval = UserDefaults.standard.double(forKey: "ddns_interval")
        if updateInterval == 0 {
            updateInterval = 300 // Default to 5 minutes
        }

        detectLocalIP()
    }

    public func start() {
        guard !isRunning else { return }
        guard !domain.isEmpty && !token.isEmpty else { return }

        isRunning = true

        // 🌙 NightGard easter egg
        print("🌙 NightGard DDNS watching over \(domain) • www.fluharty.me")

        // Perform immediate update
        Task {
            await performUpdate()
        }

        // Schedule periodic updates
        updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.performUpdate()
            }
        }
    }

    public func stop() {
        updateTimer?.invalidate()
        updateTimer = nil
        isRunning = false
        lastStatus = "Stopped"
    }

    public func performUpdate() async {
        // Detect current IP
        guard let ip = await detectCurrentIP() else {
            lastStatus = "Failed: Could not detect IP"
            return
        }

        currentIP = ip

        // Only update if IP changed
        if let lastIP = currentIP, lastIP == ip {
            lastStatus = "No change"
            return
        }

        // Perform DDNS update based on provider
        let success = await updateDDNS(ip: ip)

        if success {
            lastStatus = "Success"
            lastUpdateTime = Date()
        } else {
            lastStatus = "Failed: Update error"
        }
    }

    private func detectCurrentIP() async -> String? {
        // Use multiple IP detection services for reliability
        let services = [
            "https://api.ipify.org",
            "https://icanhazip.com",
            "https://ifconfig.me/ip"
        ]

        for serviceURL in services {
            guard let url = URL(string: serviceURL) else { continue }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let ip = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    return ip
                }
            } catch {
                continue
            }
        }

        return nil
    }

    private func updateDDNS(ip: String) async -> Bool {
        return await updateDuckDNS(ip: ip)
    }

    private func updateDuckDNS(ip: String) async -> Bool {
        // DuckDNS API: https://www.duckdns.org/update?domains={DOMAIN}&token={TOKEN}&ip={IP}
        let urlString = "https://www.duckdns.org/update?domains=\(domain)&token=\(token)&ip=\(ip)"
        guard let url = URL(string: urlString) else { return false }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let response = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                return response == "OK"
            }
        } catch {
            return false
        }

        return false
    }

    private func detectLocalIP() {
        // Use BSD sockets to get local IP
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        guard getifaddrs(&ifaddr) == 0 else {
            localIP = nil
            return
        }
        defer { freeifaddrs(ifaddr) }

        var ptr = ifaddr
        while let interface = ptr?.pointee {
            defer { ptr = interface.ifa_next }

            // Check address family is IPv4
            guard interface.ifa_addr.pointee.sa_family == UInt8(AF_INET) else { continue }

            // Get interface name - check for common network interfaces
            let name = String(cString: interface.ifa_name)
            guard name == "en0" || name == "en1" else { continue }

            // Get IP address
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            if getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                          &hostname, socklen_t(hostname.count),
                          nil, 0, NI_NUMERICHOST) == 0 {
                address = String(cString: hostname)
                break
            }
        }

        localIP = address
    }
}

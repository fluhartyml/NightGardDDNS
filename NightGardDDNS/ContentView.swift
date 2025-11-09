//
//  ContentView.swift
//  NightGardDDNS
//
//  Created by Michael Fluharty on 11/9/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showSettings = false
    @State private var ddnsService = DDNSService()

    var body: some View {
        ZStack {
            // Dark background
            Color.black.ignoresSafeArea()

            VStack(spacing: 30) {
                // Blue neon knight
                Text("♞")
                    .font(.system(size: 120))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .blue.opacity(0.8), radius: 20, x: 0, y: 0)
                    .shadow(color: .cyan.opacity(0.6), radius: 40, x: 0, y: 0)

                // NightGard branding
                Text("NightGard DDNS")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                // Status section
                VStack(spacing: 15) {
                    StatusRow(label: "Status", value: ddnsService.lastStatus)

                    if let localIP = ddnsService.localIP {
                        ClickableStatusRow(label: "Local IP", value: localIP, url: "http://\(localIP)")
                    }

                    if let publicIP = ddnsService.currentIP {
                        ClickableStatusRow(label: "Public IP", value: publicIP, url: "http://\(publicIP)")
                    }

                    if !ddnsService.domain.isEmpty {
                        ClickableStatusRow(
                            label: "Domain",
                            value: "\(ddnsService.domain).duckdns.org",
                            url: "http://\(ddnsService.domain).duckdns.org"
                        )
                    }

                    if let lastUpdate = ddnsService.lastUpdateTime {
                        StatusRow(label: "Last Update", value: formatDate(lastUpdate))
                    }

                    StatusRow(
                        label: "Service",
                        value: ddnsService.isRunning ? "Running" : "Stopped",
                        valueColor: ddnsService.isRunning ? .green : .red
                    )
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)

                // Control buttons
                HStack(spacing: 20) {
                    Button(action: {
                        showSettings = true
                    }) {
                        Label("Settings", systemImage: "gear")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue.opacity(0.3))
                            .cornerRadius(10)
                    }

                    Button(action: {
                        if ddnsService.isRunning {
                            ddnsService.stop()
                        } else {
                            ddnsService.start()
                        }
                    }) {
                        Label(
                            ddnsService.isRunning ? "Stop" : "Start",
                            systemImage: ddnsService.isRunning ? "stop.circle" : "play.circle"
                        )
                        .foregroundColor(.white)
                        .padding()
                        .background(ddnsService.isRunning ? Color.red.opacity(0.3) : Color.green.opacity(0.3))
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(ddnsService: $ddnsService)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}

struct StatusRow: View {
    let label: String
    let value: String
    var valueColor: Color = .cyan

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .foregroundColor(valueColor)
                .fontWeight(.semibold)
        }
    }
}

struct ClickableStatusRow: View {
    let label: String
    let value: String
    let url: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Button(action: {
                if let url = URL(string: url) {
                    NSWorkspace.shared.open(url)
                }
            }) {
                Text(value)
                    .foregroundColor(.cyan)
                    .fontWeight(.semibold)
                    .underline()
            }
            .buttonStyle(.plain)
            .onHover { isHovered in
                if isHovered {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

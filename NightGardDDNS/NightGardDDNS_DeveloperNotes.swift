/*

 # NightGardDDNS - Comprehensive Developer Documentation

 **Module Name:** NightGardDDNS
 **Type:** Swift Package (Reusable Library + Demo App)
 **Version:** 1.0.0 (Production Ready)
 **Created:** 2025-NOV-09
 **Developer:** Michael Fluharty (michael@fluharty.com)
 **Repository:** https://github.com/fluhartyml/NightGard/Modules/NightGardDDNS
 **Status:** ✅ Fully Working & Tested

 ---

 ## Table of Contents

 1. Project Description
 2. Features & Capabilities
 3. Technical Architecture
 4. API Documentation
 5. Demo Applications
 6. Integration Guide
 7. Build & Deployment
 8. Troubleshooting
 9. Version History

 ---

 ## 1. Project Description

 NightGardDDNS is a production-ready Swift package providing automatic Dynamic DNS (DDNS) update functionality for macOS and iOS applications. It monitors your public IP address and automatically updates your DDNS provider when changes are detected.

 **What It Does:**
 - Detects local network IP (WiFi/Ethernet)
 - Detects public internet IP via multiple fallback services
 - Updates DDNS provider when IP changes
 - Runs on configurable timer intervals (default: 5 minutes)
 - Persists settings between app launches

 **Why This Exists:**
 This module was extracted from **wWw NGPortal** (2025-11-09) as part of the NightGard Module Library initiative - creating reusable "Lego brick" Swift packages that developers can use to rapidly build applications without reinventing common functionality.

 **Supported Platforms:**
 - iOS 17+
 - macOS 14+
 - Swift 6.2+

 ---

 ## 2. Features & Capabilities

 ### Current Features (v1.0.0)

 ✅ **Automatic IP Detection**
 - Local IP: BSD sockets (getifaddrs) checking en0/en1 interfaces
 - Public IP: Multiple fallback services (ipify.org, icanhazip.com, ifconfig.me)
 - IPv4 support with proper error handling

 ✅ **DuckDNS Provider Support**
 - Full DuckDNS API integration
 - Domain and token configuration
 - Success/failure response parsing

 ✅ **Smart Update Logic**
 - Only updates when IP actually changes (reduces API calls)
 - Immediate update on service start
 - Periodic checks on timer interval
 - Prevents unnecessary updates

 ✅ **SwiftUI Integration**
 - @Observable macro for reactive UI updates
 - @MainActor thread safety
 - Real-time status updates
 - Last update timestamp tracking

 ✅ **Settings Persistence**
 - UserDefaults storage for domain, token, update interval
 - Survives app restarts
 - No external dependencies

 ✅ **Demo Applications**
 - CLI demo tool for AI assistants (`swift run DDNSDemoTool`)
 - macOS demo app with "Liquid Glass" dark theme UI
 - Blue neon knight (♞) branding with cyan gradient glow

 ✅ **Easter Egg**
 Console message: `🌙 NightGard DDNS watching over [domain] • www.fluharty.me`

 ### Future Enhancements (Planned)

 🔮 **Additional DDNS Providers**
 - Cloudflare DDNS
 - No-IP
 - Dynu
 - FreeDNS
 - Google Domains DDNS

 🔮 **Advanced Features**
 - IPv6 support
 - Custom IP detection service configuration
 - Combine publishers for reactive programming
 - Network reachability monitoring
 - Automatic retry with exponential backoff

 🔮 **Developer Experience**
 - Pre-built SwiftUI view components
 - CocoaPods support
 - Comprehensive unit test suite
 - CI/CD automation

 ---

 ## 3. Technical Architecture

 ### Core Components

 **DDNSService.swift** (223 lines)
 - Main service class
 - @MainActor @Observable for SwiftUI reactivity
 - Timer-based periodic updates
 - BSD socket IP detection
 - URLSession networking

 **Key Properties:**
 ```swift
 public var domain: String          // DuckDNS subdomain (persisted)
 public var token: String           // API token (persisted)
 public var updateInterval: TimeInterval  // Default: 300s (persisted)
 public var isRunning: Bool         // Service state
 public var lastUpdateTime: Date?   // Last successful update
 public var lastStatus: String      // Human-readable status
 public var currentIP: String?      // Public IP address
 public var localIP: String?        // Local network IP
 ```

 ### IP Detection Implementation

 **Local IP Detection (BSD Sockets):**
 ```swift
 private func detectLocalIP() {
     // Uses getifaddrs() system call
     // Checks en0 and en1 network interfaces
     // Filters for IPv4 (AF_INET) addresses
     // Falls back to nil if no interface found
 }
 ```

 **Public IP Detection (HTTP Services):**
 ```swift
 private func detectCurrentIP() async -> String? {
     // Tries multiple services in order:
     // 1. https://api.ipify.org
     // 2. https://icanhazip.com
     // 3. https://ifconfig.me/ip
     // Returns first successful response
 }
 ```

 ### DDNS Update Flow

 1. Service starts → Immediate update triggered
 2. `performUpdate()` called
 3. Detect current public IP
 4. Compare with last known IP
 5. If changed → Call `updateDDNS(ip:)`
 6. Update DuckDNS via HTTPS GET
 7. Parse response ("OK" = success)
 8. Update UI properties via @Observable
 9. Schedule next update on timer

 ### Thread Safety

 - All public methods marked @MainActor
 - Timer callbacks use `Task { @MainActor in ... }`
 - Network calls use async/await
 - No data races or concurrency issues

 ### Persistence Layer

 UserDefaults keys:
 - `ddns_domain` - String
 - `ddns_token` - String
 - `ddns_interval` - Double (seconds)

 Saved on property `didSet`, loaded in `init()`

 ---

 ## 4. API Documentation

 ### DDNSService Class

 **Initialization:**
 ```swift
 let service = DDNSService()
 // Automatically loads saved settings from UserDefaults
 // Detects local IP immediately
 ```

 **Configuration:**
 ```swift
 service.domain = "your-subdomain"     // Without .duckdns.org
 service.token = "your-api-token"       // From DuckDNS account
 service.updateInterval = 300           // Seconds (default: 5 min)
 ```

 **Control Methods:**
 ```swift
 service.start()                        // Start DDNS monitoring
 service.stop()                         // Stop monitoring
 await service.performUpdate()          // Manual update
 ```

 **Observable Properties:**
 ```swift
 service.isRunning                      // Bool - service state
 service.lastStatus                     // String - human status
 service.currentIP                      // String? - public IP
 service.localIP                        // String? - local IP
 service.lastUpdateTime                 // Date? - last success
 ```

 **Status Values:**
 - `"Idle"` - Service not started
 - `"Stopped"` - Service manually stopped
 - `"No change"` - IP unchanged since last check
 - `"Success"` - Update succeeded
 - `"Failed: Could not detect IP"` - IP detection failed
 - `"Failed: Update error"` - DDNS API call failed

 ### SwiftUI Integration Example

 ```swift
 import SwiftUI
 import NightGardDDNS

 struct ContentView: View {
     @State private var ddnsService = DDNSService()

     var body: some View {
         VStack {
             Text("Status: \(ddnsService.lastStatus)")
             Text("Public IP: \(ddnsService.currentIP ?? "Unknown")")
             Text("Local IP: \(ddnsService.localIP ?? "Unknown")")

             Button(ddnsService.isRunning ? "Stop" : "Start") {
                 if ddnsService.isRunning {
                     ddnsService.stop()
                 } else {
                     ddnsService.start()
                 }
             }
         }
     }
 }
 ```

 ---

 ## 5. Demo Applications

 ### CLI Demo Tool (For AI Assistants)

 **Location:** `Sources/DDNSDemoTool/main.swift`

 **Run Command:**
 ```bash
 swift run DDNSDemoTool
 ```

 **Purpose:**
 - Allows AI coding assistants to test the module
 - No GUI required
 - Demonstrates core functionality
 - Shows console output with easter egg

 **Sample Output:**
 ```
 🌙 NightGard DDNS Demo Tool
 ════════════════════════════
 Local IP: 192.168.1.100
 Public IP: 98.97.23.221
 ```

 ### macOS Demo App (For Human Developers)

 **Location:** `/Users/michaelfluharty/Developer/NightGard/Modules/NightGardDDNS/`

 **Files:**
 - `NightGardDDNS/ContentView.swift` - Main UI with blue neon knight
 - `NightGardDDNS/SettingsView.swift` - Configuration form
 - `NightGardDDNS/DDNSService.swift` - Core service (copy of package version)

 **Design:**
 - **Theme:** "Liquid Glass" dark mode aesthetic
 - **Icon:** Blue neon knight (♞) with cyan gradient glow
 - **Background:** Pure black
 - **Accents:** Cyan (#00FFFF) for links and status
 - **Shadows:** Dual-layer glow effect on knight

 **Features:**
 - Real-time status updates
 - Clickable IP/domain links (opens Safari)
 - Settings sheet for configuration
 - Start/Stop buttons with color coding
 - Last update timestamp
 - Service running indicator (green/red)

 **Build & Run:**
 1. Open `NightGardDDNS.xcodeproj` in Xcode
 2. Select "NightGardDDNS" scheme
 3. Build (⌘B) and Run (⌘R)
 4. App requires "Outgoing Connections (Client)" sandbox permission

 **Sandbox Configuration:**
 - App Sandbox: Enabled
 - Outgoing Connections (Client): Checked ✅
 - Allows HTTPS to ipify.org, icanhazip.com, ifconfig.me, duckdns.org

 ---

 ## 6. Integration Guide

 ### For Swift Package Manager

 **Step 1: Add Dependency**
 ```swift
 // Package.swift
 let package = Package(
     name: "YourApp",
     dependencies: [
         .package(
             url: "https://github.com/fluhartyml/NightGard/Modules/NightGardDDNS",
             from: "1.0.0"
         )
     ],
     targets: [
         .target(
             name: "YourApp",
             dependencies: ["NightGardDDNS"]
         )
     ]
 )
 ```

 **Step 2: Import and Use**
 ```swift
 import NightGardDDNS

 @State private var ddns = DDNSService()

 // Configure
 ddns.domain = "myserver"
 ddns.token = "abc123-def456-ghi789"
 ddns.updateInterval = 600  // 10 minutes

 // Start monitoring
 ddns.start()

 // Access status
 print(ddns.currentIP)          // "98.97.23.221"
 print(ddns.lastStatus)         // "Success"
 ```

 ### For Xcode Projects

 **Step 1: Add Package**
 1. File → Add Package Dependencies...
 2. Enter URL: `https://github.com/fluhartyml/NightGard/Modules/NightGardDDNS`
 3. Choose version rule: "Up to Next Major" (1.0.0 < 2.0.0)
 4. Add to your target

 **Step 2: Configure Sandbox (macOS)**
 1. Select your target → Signing & Capabilities
 2. Add "App Sandbox" capability if not present
 3. Under "Network", check "Outgoing Connections (Client)"

 **Step 3: Use in Code**
 ```swift
 import SwiftUI
 import NightGardDDNS

 @main
 struct MyApp: App {
     @State private var ddnsService = DDNSService()

     var body: some Scene {
         WindowGroup {
             ContentView(ddnsService: $ddnsService)
                 .onAppear {
                     // Auto-start if configured
                     if !ddnsService.domain.isEmpty && !ddnsService.token.isEmpty {
                         ddnsService.start()
                     }
                 }
         }
     }
 }
 ```

 ---

 ## 7. Build & Deployment

 ### Development Build

 ```bash
 # Clone repository
 git clone https://github.com/fluhartyml/NightGard.git
 cd NightGard/Modules/NightGardDDNS

 # Build package
 swift build

 # Run tests
 swift test

 # Run CLI demo
 swift run DDNSDemoTool
 ```

 ### Xcode Build

 1. Open `NightGardDDNS.xcodeproj`
 2. Select scheme: NightGardDDNS
 3. Product → Build (⌘B)
 4. Product → Run (⌘R)

 **Build Errors Resolved:**
 - ✅ NWInterface.InterfaceType.allCases (doesn't exist) → Switched to BSD sockets
 - ✅ Closure parameter type inference → Removed Network framework dependency
 - ✅ .cursor(.pointingHand) → Used .onHover + NSCursor instead
 - ✅ Sandbox blocking network → Added "Outgoing Connections" permission

 ### Distribution

 **Via GitHub:**
 - Repository: https://github.com/fluhartyml/NightGard
 - Path: /Modules/NightGardDDNS
 - Swift Package Manager compatible
 - No App Store distribution (uses custom entitlements)

 **Versioning:**
 - Semantic versioning (MAJOR.MINOR.PATCH)
 - Current: 1.0.0
 - Git tags for releases

 ---

 ## 8. Troubleshooting

 ### "Could not detect IP"

 **Cause:** Network connectivity issues or all IP detection services failed

 **Solution:**
 1. Check internet connection
 2. Verify firewall allows HTTPS outbound
 3. Check if ipify.org, icanhazip.com, ifconfig.me are accessible
 4. Ensure "Outgoing Connections (Client)" sandbox permission enabled

 ### "Update error"

 **Cause:** DuckDNS API returned non-"OK" response

 **Solution:**
 1. Verify domain exists in DuckDNS account
 2. Verify token is correct (check for copy/paste errors)
 3. Domain should NOT include ".duckdns.org" suffix
 4. Check DuckDNS service status

 ### Local IP shows "Check Network Settings"

 **Cause:** No active en0/en1 network interface with IPv4

 **Solution:**
 1. Connect to WiFi or ethernet
 2. Check System Settings → Network
 3. Verify IPv4 is configured (not just IPv6)
 4. Interface must be en0 or en1 (standard macOS naming)

 ### UI not updating when service starts

 **Cause:** Missing @Observable macro or @State binding

 **Solution:**
 1. Ensure DDNSService uses @Observable
 2. Ensure view uses @State private var ddnsService = DDNSService()
 3. Check Swift 6.2 Observation framework is available

 ### Build error: "Cannot find 'DDNSService' in scope"

 **Cause:** Module not imported

 **Solution:**
 ```swift
 import NightGardDDNS  // Add this at top of file
 ```

 ### Sandbox blocking network access

 **Cause:** Missing network entitlements

 **Solution:**
 1. Target → Signing & Capabilities
 2. Add "App Sandbox" if missing
 3. Under "Network", enable "Outgoing Connections (Client)"
 4. Clean build folder (⇧⌘K) and rebuild

 ---

 ## 9. Version History

 ### v1.0.0 (2025-NOV-09) - Initial Release ✅

 **Features:**
 - ✅ Core DDNS service with DuckDNS support
 - ✅ Local IP detection via BSD sockets
 - ✅ Public IP detection with fallback services
 - ✅ SwiftUI @Observable integration
 - ✅ UserDefaults persistence
 - ✅ CLI demo tool for AI assistants
 - ✅ macOS demo app with blue neon knight UI
 - ✅ Clickable IP/domain links
 - ✅ Settings view with Form UI
 - ✅ Timer-based automatic updates
 - ✅ Console easter egg with www.fluharty.me

 **Bug Fixes:**
 - Fixed NWInterface.InterfaceType.allCases build error
 - Fixed closure type inference with Network framework
 - Fixed .cursor() modifier not existing in SwiftUI
 - Fixed sandbox blocking network access
 - Fixed UI not updating (@Observable implementation)

 **Testing:**
 - ✅ Successfully detects local IP (192.168.x.x)
 - ✅ Successfully detects public IP from internet
 - ✅ Successfully updates nightgard.duckdns.org
 - ✅ Settings persist between app launches
 - ✅ Clickable links open Safari correctly
 - ✅ Timer updates work on 5-minute interval

 **Known Limitations:**
 - Only DuckDNS provider supported (v1.0)
 - IPv4 only (no IPv6)
 - Hardcoded IP detection services
 - Manual retry only (no automatic exponential backoff)

 **Contributors:**
 - Michael Fluharty (Architecture, Implementation, Testing)
 - Claude AI Assistant (Code generation, Build troubleshooting, Documentation)

 **Commit:** "Fix local IP detection build errors by simplifying BSD socket implementation"
 **Co-Authored-By:** Claude <noreply@anthropic.com>

 ---

 ## Easter Eggs & Branding

 🌙 **Console Message**
 When service starts:
 ```
 🌙 NightGard DDNS watching over [domain] • www.fluharty.me
 ```

 ♞ **Blue Neon Knight**
 - App icon uses chess knight (♞) character
 - Blue to cyan gradient: `[.blue, .cyan]`
 - Dual-layer glow: Blue (0.8 opacity, 20pt radius) + Cyan (0.6 opacity, 40pt radius)
 - Represents protection and vigilance over your domain

 🔗 **Clickable Links**
 - Local IP → http://192.168.x.x
 - Public IP → http://x.x.x.x
 - Domain → http://yourdomain.duckdns.org
 - All open in Safari with hand cursor on hover

 ---

 ## Additional Resources

 **DuckDNS:**
 - Website: https://www.duckdns.org
 - API Docs: https://www.duckdns.org/spec.jsp
 - Get Token: https://www.duckdns.org (login with social account)

 **Swift Package Manager:**
 - Docs: https://swift.org/package-manager
 - Conventions: https://github.com/apple/swift-package-manager

 **NightGard Module Library:**
 - Website: www.fluharty.me
 - Developer: Michael Fluharty
 - Other Modules: NightGardFileSystem, NightGardEditor (in development)

 ---

 ## License & Attribution

 **License:** GNU General Public License v3.0 (GPL v3)

 **"Share and Share Alike with Attribution Required"**

 This software is licensed under GPL v3, which means:
 - ✅ You may use, study, modify, and distribute this software freely
 - ✅ Source code must be provided with any distribution
 - ✅ All derivative works must remain open source under GPL v3
 - ✅ Attribution to Michael Fluharty as original author is REQUIRED
 - ✅ All modifications must be documented

 **Required Attribution:**
 When distributing this software or derivatives, you must:
 1. Credit Michael Fluharty as the original author
 2. Include link: https://github.com/fluhartyml
 3. Maintain GPL v3 license documentation intact
 4. Document all changes made

 **Warranty Disclaimer:**
 This software is provided "AS IS" with no warranty of any kind. The author assumes no liability for damages, data loss, or business interruption resulting from use.

 **Full License Text:**
 https://www.gnu.org/licenses/gpl-3.0.en.html

 **EULA:**
 - Web: https://fluharty.me (See wiki for complete EULA)
 - GitHub: https://github.com/fluhartyml/fluhartyml.github.io/wiki/EULA-End-User-License-Agreement

 **Support:**
 - Website: https://fluharty.me
 - GitHub Issues: https://github.com/fluhartyml/NightGard/issues
 - Email: michael@fluharty.com

 ---

 *🌙 NightGard Module Library - Reusable Swift packages for rapid development*
 *www.fluharty.me*

 */

// This file exists solely for documentation purposes.
// It is not compiled into the package.

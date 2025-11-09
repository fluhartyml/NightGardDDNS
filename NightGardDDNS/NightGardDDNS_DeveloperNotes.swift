/*

 # NightGardDDNS - Developer Notes

 **Module Name:** NightGardDDNS
 **Type:** Swift Package (Reusable Library)
 **Created:** 2025-NOV-09
 **Developer:** Michael Fluharty (michael@fluharty.com)
 **Repository:** [To be published on GitHub]

 ---

 ## Project Description

 NightGardDDNS is a Swift package providing automatic Dynamic DNS (DDNS) update functionality for macOS and iOS applications. It monitors your public IP address and automatically updates your DDNS provider when changes are detected.

 **Current Features:**
 - Automatic IP detection using multiple fallback services
 - DuckDNS provider support
 - Configurable update intervals
 - Timer-based automatic updates
 - Clean, simple API for app integration

 **Supported Platforms:**
 - iOS 17+
 - macOS 14+

 ---

 ## Project Intentions

 ### Purpose
 Create a reusable "Lego brick" module that ANY developer can drop into their app to add DDNS functionality without reinventing the wheel.

 ### Design Philosophy
 1. **General-purpose** - Not just for NightGard apps, for the entire Swift developer community
 2. **Zero dependencies** - Uses only Foundation framework
 3. **Well-documented** - Clear examples and usage instructions
 4. **Easy integration** - Swift Package Manager, one-line import
 5. **Demonstrable** - Includes CLI tool and demo app to show functionality

 ### Easter Egg
 When the service starts, it prints:
 `🌙 NightGard DDNS watching over [domain] • www.fluharty.me`

 ### Future Enhancements
 - Additional DDNS providers (Cloudflare, No-IP, etc.)
 - IPv6 support
 - Custom IP detection service configuration
 - Combine/async publisher support
 - SwiftUI view components

 ---

 ## Module Structure

 ```
 NightGardDDNS/
 ├── Package.swift              # Swift Package manifest
 ├── Sources/
 │   ├── NightGardDDNS/        # Main library
 │   │   └── DDNSService.swift  # Core service class
 │   └── DDNSDemoTool/         # CLI demo (swift run DDNSDemoTool)
 │       └── main.swift
 ├── Tests/
 │   └── NightGardDDNSTests/   # Unit tests
 └── Examples/                  # (To be created)
     └── DemoApp/              # macOS demo app with blue neon knight UI
 ```

 ---

 ## Quick Start for Developers

 **Installation:**
 ```swift
 // In Package.swift dependencies:
 .package(url: "https://github.com/fluhartyml/NightGardDDNS", from: "1.0.0")
 ```

 **Usage:**
 ```swift
 import NightGardDDNS

 let ddns = DDNSService()
 ddns.domain = "your-domain"
 ddns.token = "your-duckdns-token"
 ddns.start()  // Begins automatic updates
 ```

 **Testing:**
 ```bash
 # Run CLI demo tool
 swift run DDNSDemoTool

 # Run tests
 swift test
 ```

 ---

 ## Extracted From

 This module was extracted from **wWw NGPortal** (2025-11-09) as part of the NightGard Module Library initiative to create reusable Swift packages for rapid app development.

 ---

 *Part of the NightGard Module Library - www.fluharty.me*

 */

// This file exists solely for documentation purposes.
// It is not compiled into the package.

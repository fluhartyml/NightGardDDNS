//
//  SettingsView.swift
//  NightGardDDNS
//
//  Created by Michael Fluharty on 11/9/25.
//

import SwiftUI

struct SettingsView: View {
    @Binding var ddnsService: DDNSService
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("DDNS Configuration") {
                    TextField("Domain", text: $ddnsService.domain)
                        .textContentType(.none)
                        .autocorrectionDisabled()

                    SecureField("Token", text: $ddnsService.token)
                        .textContentType(.password)

                    Stepper("Update Interval: \(Int(ddnsService.updateInterval))s",
                            value: $ddnsService.updateInterval,
                            in: 60...3600,
                            step: 60)
                }

                Section("About") {
                    LabeledContent("Provider", value: "DuckDNS")
                    LabeledContent("Version", value: "1.0.0")
                    Link("www.fluharty.me", destination: URL(string: "https://www.fluharty.me")!)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView(ddnsService: .constant(DDNSService()))
}

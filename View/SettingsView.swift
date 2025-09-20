//
//  SettingsView.swift
//  lifehackiosapp
//
//  Created by Aleksander Blindheim on 19/09/2025.
//import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appConfig: AppConfig
    @State private var backend: String = ""
    @State private var token: String = ""

    var body: some View {
        Form {
            Section("Backend") {
                TextField("Backend URL", text: $backend)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)

                TextField("Client token", text: $token)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)

                Button("Save") {
                    appConfig.backendURL = backend
                    appConfig.clientToken = token
                }
            }
            Section {
                if let url = URL(string: "\(appConfig.backendURL)/health") {
                    Link("Open Backend Health", destination: url)
                }
            }
        }
        .onAppear {
            backend = appConfig.backendURL
            token = appConfig.clientToken
        }
        .navigationTitle("Settings")
    }
}

import SwiftUI

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
                Link("Open Backend Health", destination: URL(string: "\(appConfig.backendURL)/health")!)
            }
        }
        .onAppear {
            backend = appConfig.backendURL
            token = appConfig.clientToken
        }
        .navigationTitle("Settings")
    }
}http://:172.20.10.8:8787

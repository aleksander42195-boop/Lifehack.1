import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appConfig: AppConfig
    @State private var backend: String = ""
    @State private var token: String = ""
    @State private var pingResult: String = ""

    var body: some View {
        Form {
            Section("Backend") {
                TextField("Backend URL", text: $backend)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .keyboardType(.URL)

                TextField("Client token", text: $token)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)

                Button("Save") {
                    appConfig.backendURL = backend
                    appConfig.clientToken = token
                }

                if let healthURL = URL(string: backend).flatMap({ base in
                    // Legg til /health hvis det ikke allerede finnes
                    if base.path.hasSuffix("/health") {
                        return base
                    } else {
                        return base.appendingPathComponent("health")
                    }
                }) {
                    Link("Open Backend Health", destination: healthURL)
                }
            }

            Section("WatchConnectivity") {
                HStack {
                    Text("Watch reachable")
                    Spacer()
                    Circle()
                        .fill(Connectivity_iOS.shared.isReachable ? .green : .red)
                        .frame(width: 12, height: 12)
                }

                Button("Send ping to Watch") {
                    Task {
                        do {
                            let reply = try await Connectivity_iOS.shared.sendMessage(["type": "ping"])
                            pingResult = "Reply: \(reply)"
                        } catch {
                            pingResult = "Error: \(error.localizedDescription)"
                        }
                    }
                }

                if !pingResult.isEmpty {
                    Text(pingResult)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

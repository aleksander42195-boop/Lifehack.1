<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.healthkit</key><true/>
    <key>com.apple.developer.healthkit.access</key>
    <array>
        <string>health-share</string>
        <string>health-update</string>
    </array>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.yourcompany.lifehack</string>
    </array>
    <key>com.apple.developer.watchkit</key><true/>
</dict>
</plist>
import SwiftUI

@main
struct LifehackApp: App {
    @StateObject private var appConfig = AppConfig()
    @StateObject private var hk = HealthKitManager_iOS.shared

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appConfig)
                .task {
                    try? await hk.requestAuthorization()
                    try? await hk.fetchLatest()
                    Connectivity_iOS.shared.sendLatest(
                        hrvMs: hk.latestHRVms,
                        restingHR: hk.restingHR,
                        age: hk.age
                    )
                }
        }
    }
}

final class AppConfig: ObservableObject {
    @AppStorage("backendURL") var backendURL: String = "http://localhost:8787"
    @AppStorage("clientToken") var clientToken: String = "replace-with-a-long-random-string"
}<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>com.apple.developer.healthkit</key><true/>
  <key>com.apple.developer.healthkit.access</key>
  <array>
    <string>health-share</string>
    <string>health-update</string>
  </array>
  <key>com.apple.security.application-groups</key>
  <array>
    <string>group.com.yourcompany.lifehack</string>
  </array>
</dict>
</plist>

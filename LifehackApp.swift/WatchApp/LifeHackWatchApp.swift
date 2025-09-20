import SwiftUI

@main
struct LifehackWatchApp: App {
    @StateObject private var workout = WorkoutManager()
    @StateObject private var hk = HealthKitManager_watch.shared
    @StateObject private var wc = Connectivity_watch.shared

    var body: some Scene {
        WindowGroup {
            StartView()
                .environmentObject(workout)
                .environmentObject(hk)
                .environmentObject(wc)
                .task {
                    await hk.requestAuthorization()
                    await hk.startLiveHeartRate()
                }
        }
    }
}

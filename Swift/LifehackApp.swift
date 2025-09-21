//
//  LifehackApp.swift
//  lifehackiosapp
//
//  Created by Aleksander Blindheim on 21/09/2025.
//@main
struct LifehackApp: App {
    @StateObject private var appConfig = AppConfig()
    @StateObject private var hk = HealthKitManager_iOS.shared

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appConfig)
                .task {
                    // 1) Aktiver WC
                    Connectivity_iOS.shared.activate()

                    // 2) HealthKit (hent verdier)
                    try? await hk.requestAuthorization()
                    try? await hk.fetchLatest()

                    // 3) Send siste HRV/hvilepuls/alder til watch
                    Connectivity_iOS.shared.sendLatest(
                        hrvMs: hk.latestHRVms,
                        restingHR: hk.restingHR,
                        age: hk.age
                    )
                }
        }
    }
}


//
//  onAppear.swift
//  Lifehack
//
//  Created by Aleksander Blindheim on 18/09/2025.
//import SwiftUI

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
                    Connectivity_iOS.shared.sendLatest(hrvMs: hk.latestHRVms, restingHR: hk.restingHR, age: hk.age)
                }
        }
    }
}


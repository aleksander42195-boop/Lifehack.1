//
//  LifehackApp.swift
//  lifehackiosapp
//
//  Created by Aleksander Blindheim on 21/09/2025.
//import SwiftUI

@main
struct LifehackApp: App {
    @StateObject private var appConfig = AppConfig()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appConfig)
                .task {
                    // Viktig: aktiver iOS-sesjonen, ellers svarer ikke appen watch-en
                    Connectivity_iOS.shared.activate()
                }
        }
    }
}

final class AppConfig: ObservableObject {
    @AppStorage("backendURL") var backendURL: String = "http://localhost:8787"
    @AppStorage("clientToken") var clientToken: String = "replace-with-a-long-random-string"
}


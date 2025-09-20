//
//  RootTabView.swift
//  lifehackiosapp
//
//  Created by Aleksander Blindheim on 19/09/2025.
//import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            HomeView().tabItem { Label("Home", systemImage: "house") }
            NutritionView().tabItem { Label("Nutrition", systemImage: "fork.knife") }
            CoachingView().tabItem { Label("Coaching", systemImage: "message") }
            SettingsView().tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

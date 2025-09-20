//
//  HomeView.swift
//  lifehackiosapp
//
//  Created by Aleksander Blindheim on 19/09/2025.
//import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Welcome to Lifehack").font(.largeTitle).bold()
                Text("Track meals, chat with your AI coach, and keep things simple.")
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

//
//  StartView.swift
//  lifehackiosapp
//
//  Created by Aleksander Blindheim on 19/09/2025.
//import SwiftUI

struct StartView: View {
    @EnvironmentObject var workout: WorkoutManager
    @EnvironmentObject var hk: HealthKitManager_watch
    @EnvironmentObject var wc: Connectivity_watch

    var zones: HRZones {
        makeZones(
            age: wc.personalization.age,
            restingHR: wc.personalization.restingHR,
            latestHRVms: wc.personalization.latestHRVms
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                Text("HR: \(hk.liveHR) bpm").font(.title2).bold()
                if let z = zones.zone(for: hk.liveHR) {
                    Text(z.name).font(.headline)
                    Text(z.rangeText).font(.caption)
                } else { Text("Utenfor sone").font(.subheadline) }
                NavigationLink("Start økt") { LiveWorkoutView(zones: zones) }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Lifehack")
        }
    }
}

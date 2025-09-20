//
//  LiveWorkoutView.swift
//  lifehackiosapp
//
//  Created by Aleksander Blindheim on 19/09/2025.
//import SwiftUI

struct LiveWorkoutView: View {
    @EnvironmentObject var workout: WorkoutManager
    @EnvironmentObject var hk: HealthKitManager_watch
    let zones: HRZones
    @State private var started = false

    var body: some View {
        VStack(spacing: 8) {
            Text("Tid: \(Int(workout.elapsed)) s")
            Text("Puls: \(hk.liveHR) bpm").font(.title2).bold()
            if let z = zones.zone(for: hk.liveHR) {
                Text(z.name).bold()
                Text(z.rangeText).font(.caption)
            }
            HStack {
                if !started {
                    Button("Start") { Task { await workout.start(); started = true } }
                        .buttonStyle(.borderedProminent)
                } else {
                    Button("Pause") { workout.pause() }
                    Button("Fortsett") { workout.resume() }
                    Button("Stopp") { workout.end(); started = false }
                }
            }
        }
        .padding()
        .onDisappear { if started { workout.end() } }
    }
}

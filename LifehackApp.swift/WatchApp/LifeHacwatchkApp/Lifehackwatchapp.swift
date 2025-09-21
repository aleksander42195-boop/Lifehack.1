//
//  Lifehackwatchapp.swift
//  lifehackiosapp
//
//  Created by Aleksander Blindheim on 21/09/2025.
//

import SwiftUI

/// Denne filen var tidligere en alternativ @main for watchOS.
/// For å unngå kollisjon med LifehackWatchApp.swift (@main),
/// er den nå en enkel hjelpevisning du kan bruke i previews om ønskelig.
struct ConnectivityDebugView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("WatchConnectivity Debug")
                .font(.headline)
            Text("App entry point er LifehackWatchApp.swift.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text("Når Connectivity_watch er oppgradert, kan du lage en egen debug-side som bruker den.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ConnectivityDebugView()
}

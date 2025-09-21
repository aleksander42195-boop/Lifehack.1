//
//  codesnippet.swift
//  lifehackiosapp
//
//  Created by Aleksander Blindheim on 21/09/2025.
//

struct WCDemoView: View {
    @EnvironmentObject var wc: Connectivity_watch
    @State private var result: String = ""

    var body: some View {
        VStack {
            HStack {
                Text("iPhone reachable")
                Circle().fill(wc.isReachable ? .green : .red).frame(width: 10, height: 10)
            }
            Button("Ping iPhone") {
                Task {
                    do {
                        let reply = try await wc.ping()
                        result = "Reply: \(reply)"
                    } catch {
                        result = "Error: \(error.localizedDescription)"
                    }
                }
            }
            if !result.isEmpty { Text(result).font(.footnote).foregroundStyle(.secondary) }
        }
        .padding()
    }
}

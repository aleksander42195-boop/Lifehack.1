//
//  Untitled.swift
//  lifehackiosapp
//
//  Created by Aleksander Blindheim on 19/09/2025.
//import SwiftUI

struct NutritionView: View {
    @State private var items: [FoodEntry] = []
    @State private var name: String = ""
    @State private var grams: String = ""
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                TextField("Food name", text: $name)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                HStack {
                    TextField("Grams", text: $grams).keyboardType(.decimalPad)
                    TextField("Notes (optional)", text: $notes)
                }
                Button {
                    if let g = Double(grams), !name.isEmpty {
                        items.append(.init(name: name, grams: g, notes: notes.isEmpty ? nil : notes))
                        name = ""; grams = ""; notes = ""
                    }
                } label: {
                    Label("Add item", systemImage: "plus.circle.fill").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                List {
                    ForEach(items) { item in
                        VStack(alignment: .leading) {
                            Text("\(item.name) • \(Int(item.grams)) g").bold()
                            if let n = item.notes, !n.isEmpty {
                                Text(n).font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { idx in items.remove(atOffsets: idx) }
                }
            }
            .padding()
            .navigationTitle("Nutrition")
        }
    }
}

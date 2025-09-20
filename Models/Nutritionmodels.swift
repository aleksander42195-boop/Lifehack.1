//
//  Nutritionmodels.swift
//  lifehackiosapp
//
//  Created by Aleksander Blindheim on 19/09/2025.
//import Foundation

struct FoodEntry: Identifiable, Codable {
    let id: UUID
    var name: String
    var grams: Double
    var notes: String?

    init(id: UUID = UUID(), name: String, grams: Double, notes: String? = nil) {
        self.id = id
        self.name = name
        self.grams = grams
        self.notes = notes
    }
}

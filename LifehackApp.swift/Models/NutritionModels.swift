import Foundation

/// Makronæringsstoffer for et måltid eller dagssum
struct NutritionMacros: Codable {
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    
    static let zero = NutritionMacros(calories: 0, protein: 0, carbs: 0, fat: 0)
    
    /// Legg sammen to NutritionMacros
    static func + (lhs: NutritionMacros, rhs: NutritionMacros) -> NutritionMacros {
        return NutritionMacros(
            calories: lhs.calories + rhs.calories,
            protein: lhs.protein + rhs.protein,
            carbs: lhs.carbs + rhs.carbs,
            fat: lhs.fat + rhs.fat
        )
    }
}

/// Ett enkelt måltid
struct Meal: Identifiable, Codable {
    let id: UUID
    var name: String
    var macros: NutritionMacros
    var timestamp: Date
    
    init(id: UUID = UUID(), name: String, macros: NutritionMacros, timestamp: Date = Date()) {
        self.id = id
        self.name = name
        self.macros = macros
        self.timestamp = timestamp
    }
}

/// Dagslogg (samling av måltider)
struct DayNutrition: Identifiable, Codable {
    let id: UUID
    var date: Date
    var meals: [Meal]
    
    init(id: UUID = UUID(), date: Date = Date(), meals: [Meal] = []) {
        self.id = id
        self.date = date
        self.meals = meals
    }
    
    /// Beregn total macros for dagen
    var total: NutritionMacros {
        meals.map { $0.macros }.reduce(.zero, +)
    }
}

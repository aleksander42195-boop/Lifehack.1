
import Foundation

/// En enkelt pulssone
struct HRZone: Identifiable, Codable {
    let id: Int
    let minHR: Int
    let maxHR: Int
    let label: String
    let colorHex: String   // for UI-visualisering senere
}

/// En gruppe av soner + hjelpefunksjon for å slå opp hvilken sone en gitt puls hører til
struct HRZones: Codable {
    let zones: [HRZone]

    func zone(for heartRate: Int) -> HRZone? {
        return zones.first { hrz in
            heartRate >= hrz.minHR && heartRate <= hrz.maxHR
        }
    }
}

/// Regn ut HR-soner fra alder, hvilepuls og HRV
/// - Parameter age: alder i år
/// - Parameter restingHR: hvilepuls
/// - Parameter latestHRVms: siste HRV i millisekunder (brukes til finjustering)
func makeZones(age: Int, restingHR: Int, latestHRVms: Double?) -> HRZones {
    // Estimer maksimal puls
    let maxHR = 220 - age
    
    // Reserve Capacity = maxHR - restingHR
    let reserve = maxHR - restingHR
    
    // HRV-justering (enkel tilpasning: høyere HRV → litt lavere pulser i lavere soner)
    let adjust: Double
    if let hrv = latestHRVms {
        if hrv > 70 {
            adjust = -0.05
        } else if hrv < 30 {
            adjust = 0.05
        } else {
            adjust = 0.0
        }
    } else {
        adjust = 0.0
    }

    // Soner (Karvonen-metoden, justert)
    let multipliers: [(Double, Double, String, String)] = [
        (0.50, 0.60, "Sone 1", "#4CAF50"), // grønn
        (0.60, 0.70, "Sone 2", "#8BC34A"),
        (0.70, 0.80, "Sone 3", "#FFC107"),
        (0.80, 0.90, "Sone 4", "#FF9800"),
        (0.90, 1.00, "Sone 5", "#F44336")  // rød
    ]
    
    var zones: [HRZone] = []
    for (index, multi) in multipliers.enumerated() {
        let min = Int(Double(reserve) * (multi.0 + adjust) + Double(restingHR))
        let max = Int(Double(reserve) * (multi.1 + adjust) + Double(restingHR))
        let z = HRZone(id: index + 1, minHR: min, maxHR: max, label: multi.2, colorHex: multi.3)
        zones.append(z)
    }
    
    return HRZones(zones: zones)
}

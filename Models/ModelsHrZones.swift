//
//  ModelsHrZones.swift
//  Lifehack
//
//  Created by Aleksander Blindheim on 18/09/2025.
//import Foundation

public struct HRZones: Codable, Equatable {
    public struct Zone: Codable, Equatable, Identifiable {
        public let id: Int
        public let name: String
        public let lower: Int
        public let upper: Int
        public var rangeText: String { "\(lower)–\(upper) bpm" }
    }
    public let zones: [Zone]
    public func zone(for hr: Int) -> Zone? { zones.first{ hr >= $0.lower && hr <= $0.upper } }
}

/// Enkel kalkulasjon: beregn maxHR ≈ 208 - 0.7*alder. Justér sonebredder basert på HRV (SDNN ms).
/// *Høy HRV* → bredere sone 2–3, *lav HRV* → smalere sone 3–4. Dette er ikke medisinsk råd.
public func makeZones(age: Int, restingHR: Int?, latestHRVms: Double?) -> HRZones {
    let maxHR = max(150, Int((208.0 - 0.7 * Double(age)).rounded())) // fallback
    let rhr = restingHR ?? 65

    // HRV justeringsfaktor (30–70ms typisk; clamps 15–100ms)
    let hrv = min(100.0, max(15.0, latestHRVms ?? 30.0))
    let flex = (hrv - 30.0) / 70.0 // -? til 1; ~0 ved 30ms

    // Baseline prosentgrenser
    var z1u = 0.60, z2u = 0.70, z3u = 0.80, z4u = 0.90

    // Juster: høy HRV → litt høyere terskler i sone 2–3
    z2u += 0.03 * flex
    z3u += 0.03 * flex

    let z1 = (Double(rhr) ... Double(Int(Double(maxHR) * z1u)))
    let z2 = (Double(Int(Double(maxHR) * z1u)+1) ... Double(Int(Double(maxHR) * z2u)))
    let z3 = (Double(Int(Double(maxHR) * z2u)+1) ... Double(Int(Double(maxHR) * z3u)))
    let z4 = (Double(Int(Double(maxHR) * z3u)+1) ... Double(Int(Double(maxHR) * z4u)))
    let z5 = (Double(Int(Double(maxHR) * z4u)+1) ... Double(maxHR))

    func intRange(_ r: ClosedRange<Double>) -> (Int, Int) {
        (Int(r.lowerBound.rounded()), Int(r.upperBound.rounded()))
    }

    let (z1l,z1uInt) = intRange(z1)
    let (z2l,z2uInt) = intRange(z2)
    let (z3l,z3uInt) = intRange(z3)
    let (z4l,z4uInt) = intRange(z4)
    let (z5l,z5uInt) = intRange(z5)

    return HRZones(zones: [
        .init(id:1, name:"Sone 1 (lett)", lower:z1l, upper:z1uInt),
        .init(id:2, name:"Sone 2 (langkjør)", lower:z2l, upper:z2uInt),
        .init(id:3, name:"Sone 3 (moderat)", lower:z3l, upper:z3uInt),
        .init(id:4, name:"Sone 4 (hard)", lower:z4l, upper:z4uInt),
        .init(id:5, name:"Sone 5 (maks)", lower:z5l, upper:z5uInt),
    ])
}
import Foundation

public struct HRZones: Codable, Equatable {
    public struct Zone: Codable, Equatable, Identifiable {
        public let id: Int
        public let name: String
        public let lower: Int
        public let upper: Int
        public var rangeText: String { "\(lower)–\(upper) bpm" }
    }
    public let zones: [Zone]
    public func zone(for hr: Int) -> Zone? { zones.first{ hr >= $0.lower && hr <= $0.upper } }
}

public func makeZones(age: Int, restingHR: Int?, latestHRVms: Double?) -> HRZones {
    let maxHR = max(150, Int((208.0 - 0.7 * Double(age)).rounded()))
    let rhr = restingHR ?? 65
    let hrv = min(100.0, max(15.0, latestHRVms ?? 30.0))
    let flex = (hrv - 30.0) / 70.0

    var z1u = 0.60, z2u = 0.70, z3u = 0.80, z4u = 0.90
    z2u += 0.03 * flex
    z3u += 0.03 * flex

    func bp(_ p: Double) -> Int { Int((Double(maxHR) * p).rounded()) }

    let zones = [
        (Int(rhr)   , bp(z1u), "Sone 1 (lett)"),
        (bp(z1u)+1  , bp(z2u), "Sone 2 (langkjør)"),
        (bp(z2u)+1  , bp(z3u), "Sone 3 (moderat)"),
        (bp(z3u)+1  , bp(z4u), "Sone 4 (hard)"),
        (bp(z4u)+1  , maxHR  , "Sone 5 (maks)")
    ].enumerated().map { idx, z in
        HRZones.Zone(id: idx+1, name: z.2, lower: z.0, upper: z.1)
    }

    return HRZones(zones: zones)
}

//
//  HealthKitManager.swift
//  Lifehack
//
//  Created by Aleksander Blindheim on 18/09/2025.
//import Foundation
import HealthKit

final class HealthKitManager_iOS: ObservableObject {
    static let shared = HealthKitManager_iOS()
    private let store = HKHealthStore()

    @Published var latestHRVms: Double?
    @Published var restingHR: Int?
    @Published var age: Int = 40

    private init() { computeAge() }

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let read: Set = [
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.workoutType()
        ]
        let share: Set = [ HKObjectType.workoutType() ]
        try await store.requestAuthorization(toShare: share, read: read)
    }

    func fetchLatest() async throws {
        async let hrv = latestSample(.heartRateVariabilitySDNN,
                                     unit: .secondUnit(with: .milli))
        async let rhr = latestSample(.restingHeartRate,
                                     unit: HKUnit.count().unitDivided(by: .minute()))
        let (hrvVal, rhrVal) = try await (hrv, rhr)
        if let hrvVal { latestHRVms = hrvVal }
        if let rhrVal { restingHR = Int(rhrVal) }
    }

    private func latestSample(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async throws -> Double? {
        guard let qt = HKObjectType.quantityType(forIdentifier: id) else { return nil }
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let q = HKSampleQueryDescriptor(predicates: [.sample(type: qt)], sortDescriptors: [sort], limit: 1)
        let results = try await q.result(for: store)
        guard let s = results.first as? HKQuantitySample else { return nil }
        return s.quantity.doubleValue(for: unit)
    }

    private func computeAge() {
        do {
            let dob = try store.dateOfBirthComponents()
            if let y = dob.year {
                let cal = Calendar.current
                let now = cal.dateComponents([.year], from: Date())
                if let ny = now.year { age = max(10, ny - y) }
            }
        } catch { /* fallback 40 */ }
    }
}

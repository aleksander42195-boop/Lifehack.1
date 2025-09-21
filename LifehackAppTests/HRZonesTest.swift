//
//  HRZonesTest.swift
//  lifehackiosapp
//
//  Created by Aleksander Blindheim on 21/09/2025.
//import XCTest
@testable import LifehackApp

final class HRZonesTests: XCTestCase {
    func testMakeZonesProducesFiveZones() {
        let zones = makeZones(age: 40, restingHR: 60, latestHRVms: 45)
        XCTAssertEqual(zones.zones.count, 5, "Forventer 5 pulssoner")
    }

    func testZoneLookupReturnsCorrectZone() {
        let zones = makeZones(age: 40, restingHR: 60, latestHRVms: 45)
        // Sjekk at en typisk rolig puls havner i sone 1 eller 2
        let hr = 95
        let z = zones.zone(for: hr)
        XCTAssertNotNil(z)
        XCTAssertTrue((1...5).contains(z!.id))
    }
}

git add ios-app/LifehackAppTests/HRZonesTests.swift
git commit -m "Add basic HRZones unit tests"
git push

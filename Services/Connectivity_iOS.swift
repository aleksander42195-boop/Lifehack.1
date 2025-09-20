//
//  APIService.swift
//  Lifehack
//
//  Created by Aleksander Blindheim on 18/09/2025.
//import Foundation
import WatchConnectivity

final class Connectivity_iOS: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = Connectivity_iOS()
    private override init() { super.init(); activate() }

    private var session: WCSession? { WCSession.isSupported() ? WCSession.default : nil }

    func activate() {
        session?.delegate = self
        session?.activate()
    }

    func sendLatest(hrvMs: Double?, restingHR: Int?, age: Int) {
        guard let s = session, s.isPaired, s.isWatchAppInstalled else { return }
        var payload: [String: Any] = ["age": age]
        if let hrvMs { payload["hrvMs"] = hrvMs }
        if let restingHR { payload["restingHR"] = restingHR }
        s.transferCurrentComplicationUserInfo(payload)
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    #endif
}

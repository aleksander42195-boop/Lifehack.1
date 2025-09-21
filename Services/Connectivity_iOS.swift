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
}import Foundation
import WatchConnectivity
import Combine

/// iOS-side av WatchConnectivity.
final class Connectivity_iOS: NSObject, ObservableObject {
    static let shared = Connectivity_iOS()

    @Published var lastReceivedMessage: [String: Any] = [:]
    @Published var isReachable: Bool = false

    private var session: WCSession? {
        WCSession.isSupported() ? WCSession.default : nil
    }

    private override init() {
        super.init()
    }

    // MARK: Lifecycle
    func activate() {
        guard let s = session else { return }
        s.delegate = self
        s.activate()
        isReachable = s.isReachable
    }

    // MARK: Outbound (iPhone -> Watch)
    func sendLatest(hrvMs: Double?, restingHR: Int?, age: Int) {
        guard let s = session, s.isPaired, s.isWatchAppInstalled else { return }
        var payload: [String: Any] = ["age": age]
        if let hrvMs { payload["hrvMs"] = hrvMs }
        if let restingHR { payload["restingHR"] = restingHR }
        s.transferCurrentComplicationUserInfo(payload) // robust bakgrunnslevering
    }

    func sendMessage(text: String, completion: ((Result<[String: Any], Error>) -> Void)? = nil) {
        guard let s = session, s.isReachable else {
            completion?(.failure(NSError(domain: "Connectivity", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Watch not reachable"])) )
            return
        }
        let msg: [String: Any] = ["type": "text", "value": text]
        s.sendMessage(msg, replyHandler: { reply in
            DispatchQueue.main.async { completion?(.success(reply)) }
        }, errorHandler: { err in
            DispatchQueue.main.async { completion?(.failure(err)) }
        })
    }

    func sendApplicationContext(_ context: [String: Any]) {
        guard let s = session, s.isPaired, s.isWatchAppInstalled else { return }
        do { try s.updateApplicationContext(context) }
        catch { print("updateApplicationContext error:", error) }
    }
}

// MARK: - WCSessionDelegate
extension Connectivity_iOS: WCSessionDelegate {
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        DispatchQueue.main.async { self.isReachable = session.isReachable }
        if let error { print("WCSession activation error:", error) }
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async { self.isReachable = session.isReachable }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any],
                 replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async { self.lastReceivedMessage = message }

        if let type = message["type"] as? String, type == "ping" {
            replyHandler(["ok": true, "from": "iphone"])
            return
        }
        replyHandler(["ok": true, "echo": message])
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async { self.lastReceivedMessage = applicationContext }
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async { self.lastReceivedMessage = userInfo }
    }
}

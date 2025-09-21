import Foundation
import WatchConnectivity
import Combine
import os

@MainActor
final class Connectivity_watch: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = Connectivity_watch()

    // Status til UI
    @Published var isReachable: Bool = false
    @Published var personalization = Personalization()

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Connectivity", category: "Connectivity_watch")

    private var session: WCSession? {
        WCSession.isSupported() ? WCSession.default : nil
    }

    private override init() {
        super.init()
        if let s = session {
            s.delegate = self
            s.activate()
            self.isReachable = s.isReachable
        } else {
            logger.error("WCSession is not supported on this device.")
        }
    }

    // MARK: - Outbound (Watch -> iPhone)

    /// Rask ping til iPhone. Krever at iPhone-appen er reachable i øyeblikket.
    func sendPing(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let s = session, s.isReachable else {
            completion(.failure(NSError(domain: "Connectivity", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "iPhone not reachable"])))
            return
        }
        let msg: [String: Any] = ["type": "ping", "from": "watch"]
        s.sendMessage(msg, replyHandler: { reply in
            Task { @MainActor in completion(.success(reply)) }
        }, errorHandler: { err in
            Task { @MainActor in completion(.failure(err)) }
        })
    }

    /// Async/await-variant for ping.
    func ping() async throws -> [String: Any] {
        try await withCheckedThrowingContinuation { cont in
            self.sendPing { result in
                switch result {
                case .success(let reply): cont.resume(returning: reply)
                case .failure(let error): cont.resume(throwing: error)
                }
            }
        }
    }

    /// Send userInfo (bakgrunnslevering) – valgfri helper hvis du vil pushe noe til iPhone.
    func sendUserInfo(_ info: [String: Any]) {
        guard let s = session else { return }
        s.transferUserInfo(info)
        logger.debug("transferUserInfo queued: \(String(describing: info))")
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        self.isReachable = session.isReachable
        if let error {
            logger.error("WCSession activation error: \(error.localizedDescription, privacy: .public)")
        } else {
            logger.debug("WCSession activated with state: \(String(describing: activationState.rawValue))")
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        self.isReachable = session.isReachable
        logger.debug("Reachability changed: \(session.isReachable ? "reachable" : "not reachable")")
    }

    // Rask melding uten reply
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        logger.debug("didReceiveMessage (no reply): \(String(describing: message))")
        // Her kan du oppdatere UI eller state ved behov
    }

    // Rask melding med reply
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        logger.debug("didReceiveMessage (with reply): \(String(describing: message))")

        // Håndter “ping” fra iPhone
        if let type = message["type"] as? String, type == "ping" {
            replyHandler(["ok": true, "from": "watch"])
            return
        }

        // Echo som default
        replyHandler(["ok": true, "echo": message, "from": "watch"])
    }

    // Mottar userInfo fra iPhone (inkl. transferCurrentComplicationUserInfo)
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        var p = personalization
        if let a = userInfo["age"] as? Int { p.age = a }
        if let r = userInfo["restingHR"] as? Int { p.restingHR = r }
        if let h = userInfo["hrvMs"] as? Double { p.latestHRVms = h }
        self.personalization = p
        logger.debug("didReceiveUserInfo -> personalization updated: age=\(p.age), rhr=\(p.restingHR ?? -1), hrv=\(p.latestHRVms ?? -1)")
    }

    // Mottar applicationContext (bakgrunn, siste tilstand)
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        self.session(session, didReceiveUserInfo: applicationContext)
        logger.debug("didReceiveApplicationContext")
    }
}

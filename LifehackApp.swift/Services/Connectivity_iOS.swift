import Foundation
import WatchConnectivity
import Combine
import os

/// iOS-side av WatchConnectivity.
/// Bruk:
/// 1) Kall Connectivity_iOS.shared.activate() tidlig (f.eks. i App .task)
/// 2) Bruk sendLatest(...) for å dytte HR/HRV m.m. til klokken
/// 3) Bruk sendMessage(text:) eller async sendMessage(_:) for raske meldinger
/// 4) Bruk sendApplicationContext(_:) / sendUserInfo(_:) / sendCurrentComplicationUserInfo(_:) for robust bakgrunnslevering
/// 5) Bruk sendFile(url:metadata:) for større payloads
@MainActor
final class Connectivity_iOS: NSObject, ObservableObject {
    static let shared = Connectivity_iOS()

    // Publiserbart til UI
    @Published var lastReceivedMessage: [String: Any] = [:]
    @Published var isReachable: Bool = false
    @Published var isPaired: Bool = false
    @Published var isWatchAppInstalled: Bool = false
    @Published var activationState: WCSessionActivationState = .notActivated

    // Combine-strømmer for de som vil lytte reaktivt
    let messages = PassthroughSubject<[String: Any], Never>()
    let userInfo = PassthroughSubject<[String: Any], Never>()
    let applicationContext = CurrentValueSubject<[String: Any], Never>([:])
    let fileTransfers = PassthroughSubject<URL, Never>() // Mottatte filer (lokale midlertidige URL-er)

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Connectivity", category: "Connectivity_iOS")

    private var session: WCSession? {
        WCSession.isSupported() ? WCSession.default : nil
    }

    private override init() {
        super.init()
    }

    // MARK: - Lifecycle

    func activate() {
        guard let s = session else {
            logger.error("WCSession is not supported on this device.")
            return
        }
        s.delegate = self
        s.activate()

        // Oppdater kjent status umiddelbart
        self.isReachable = s.isReachable
        self.isPaired = s.isPaired
        self.isWatchAppInstalled = s.isWatchAppInstalled
        // activationState oppdateres i delegate
        logger.debug("WCSession.activate() called. paired=\(self.isPaired), installed=\(self.isWatchAppInstalled), reachable=\(self.isReachable)")
    }

    // MARK: - Outbound (iPhone -> Watch)

    /// Send “siste status” til watch. Tåler at klokken ikke er aktiv (bruker background transfer).
    func sendLatest(hrvMs: Double?, restingHR: Int?, age: Int) {
        guard let s = session, s.isPaired, s.isWatchAppInstalled else {
            logger.debug("sendLatest skipped (not paired or app not installed).")
            return
        }
        var payload: [String: Any] = ["age": age]
        if let hrvMs { payload["hrvMs"] = hrvMs }
        if let restingHR { payload["restingHR"] = restingHR }

        // Robust bakgrunnslevering
        s.transferCurrentComplicationUserInfo(payload)
        logger.debug("transferCurrentComplicationUserInfo sent: \(String(describing: payload))")
    }

    /// Send en liten melding som krever rask respons (hvis watch er “reachable”)
    func sendMessage(text: String, completion: ((Result<[String: Any], Error>) -> Void)? = nil) {
        guard let s = session, s.isReachable else {
            completion?(.failure(NSError(domain: "Connectivity", code: -1,
                                         userInfo: [NSLocalizedDescriptionKey: "Watch not reachable"])))
            return
        }
        let msg: [String: Any] = ["type": "text", "value": text]
        s.sendMessage(msg, replyHandler: { reply in
            Task { @MainActor in completion?(.success(reply)) }
        }, errorHandler: { err in
            Task { @MainActor in completion?(.failure(err)) }
        })
    }

    /// Async/await-variant for å sende melding og få reply.
    func sendMessage(_ message: [String: Any]) async throws -> [String: Any] {
        try await withCheckedThrowingContinuation { cont in
            guard let s = self.session, s.isReachable else {
                cont.resume(throwing: NSError(domain: "Connectivity", code: -1,
                                              userInfo: [NSLocalizedDescriptionKey: "Watch not reachable"]))
                return
            }
            s.sendMessage(message, replyHandler: { reply in
                cont.resume(returning: reply)
            }, errorHandler: { error in
                cont.resume(throwing: error)
            })
        }
    }

    /// Send større/persistent data (havner i kø, leveres når watch er klar)
    func sendApplicationContext(_ context: [String: Any]) {
        guard let s = session, s.isPaired, s.isWatchAppInstalled else {
            logger.debug("sendApplicationContext skipped (not paired or app not installed).")
            return
        }
        do {
            try s.updateApplicationContext(context)
            logger.debug("updateApplicationContext sent: \(String(describing: context))")
        } catch {
            logger.error("updateApplicationContext error: \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Enkelt helper for transferUserInfo (legges i kø og leveres i bakgrunnen).
    func sendUserInfo(_ info: [String: Any]) {
        guard let s = session, s.isPaired, s.isWatchAppInstalled else {
            logger.debug("sendUserInfo skipped (not paired or app not installed).")
            return
        }
        s.transferUserInfo(info)
        logger.debug("transferUserInfo queued: \(String(describing: info))")
    }

    /// Enkelt helper for complication-varianten (robust bakgrunnslevering).
    func sendCurrentComplicationUserInfo(_ info: [String: Any]) {
        guard let s = session, s.isPaired, s.isWatchAppInstalled else {
            logger.debug("sendCurrentComplicationUserInfo skipped (not paired or app not installed).")
            return
        }
        s.transferCurrentComplicationUserInfo(info)
        logger.debug("transferCurrentComplicationUserInfo queued: \(String(describing: info))")
    }

    // MARK: - File transfer

    /// Overfør en fil til klokken. `metadata` kan brukes til å beskrive innholdet.
    func sendFile(url: URL, metadata: [String: Any]? = nil) {
        guard let s = session, s.isPaired, s.isWatchAppInstalled else {
            logger.debug("sendFile skipped (not paired or app not installed).")
            return
        }
        s.transferFile(url, metadata: metadata)
        logger.debug("transferFile enqueued: \(url.lastPathComponent, privacy: .public)")
    }
}

// MARK: - WCSessionDelegate
extension Connectivity_iOS: WCSessionDelegate {
    // iOS
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            self.activationState = activationState
            self.isReachable = session.isReachable
            self.isPaired = session.isPaired
            self.isWatchAppInstalled = session.isWatchAppInstalled
        }
        if let error {
            logger.error("WCSession activation error: \(error.localizedDescription, privacy: .public)")
        } else {
            logger.debug("WCSession activated with state: \(String(describing: activationState.rawValue))")
        }
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        logger.debug("sessionDidBecomeInactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        logger.debug("sessionDidDeactivate - reactivating WCSession.default")
        WCSession.default.activate()
    }
    #endif

    func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            self.isReachable = session.isReachable
        }
        logger.debug("Reachability changed: \(session.isReachable ? "reachable" : "not reachable")")
    }

    // Rask melding uten reply
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        Task { @MainActor in
            self.lastReceivedMessage = message
            self.messages.send(message)
        }
        logger.debug("didReceiveMessage (no reply): \(String(describing: message))")
    }

    // Rask melding med reply
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        Task { @MainActor in
            self.lastReceivedMessage = message
            self.messages.send(message)
        }

        // Eksempel: “ping”
        if let type = message["type"] as? String, type == "ping" {
            replyHandler(["ok": true, "from": "iphone"])
            logger.debug("Replied to ping from watch.")
            return
        }

        // Echo som default
        replyHandler(["ok": true, "echo": message])
        logger.debug("Echoed message to watch.")
    }

    // Mottar data i bakgrunnen (ikke krav om reachable)
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        Task { @MainActor in
            self.lastReceivedMessage = applicationContext
            self.applicationContext.send(applicationContext)
        }
        logger.debug("didReceiveApplicationContext: \(String(describing: applicationContext))")
    }

    // Mottar userInfo-pakker (inkl. transferCurrentComplicationUserInfo)
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        Task { @MainActor in
            self.lastReceivedMessage = userInfo
            self.userInfo.send(userInfo)
        }
        logger.debug("didReceiveUserInfo: \(String(describing: userInfo))")
    }

    // File transfer mottak (fra watch til iPhone)
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        Task { @MainActor in
            self.fileTransfers.send(file.fileURL)
        }
        logger.debug("didReceive file: \(file.fileURL.lastPathComponent, privacy: .public) metadata: \(String(describing: file.metadata))")
    }
}

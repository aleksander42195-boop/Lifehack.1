import Foundation
import WatchConnectivity
import Combine

final class Connectivity_watch: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = Connectivity_watch()
    @Published var personalization = Personalization()

    private override init() {
        super.init()
        if WCSession.isSupported() {
            let s = WCSession.default
            s.delegate = self
            s.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        var p = personalization
        if let a = userInfo["age"] as? Int { p.age = a }
        if let r = userInfo["restingHR"] as? Int { p.restingHR = r }
        if let h = userInfo["hrvMs"] as? Double { p.latestHRVms = h }
        DispatchQueue.main.async { self.personalization = p }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        session(session, didReceiveUserInfo: applicationContext)
    }
}

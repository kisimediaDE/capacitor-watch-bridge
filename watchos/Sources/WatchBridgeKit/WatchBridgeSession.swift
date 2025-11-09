import Combine
import Foundation
import WatchConnectivity

/// Public session helper class for watchOS.
/// Uses the App Group ID from the Info.plist (key: "WatchBridgeAppGroupId")
/// and optionally writes incoming JSON data to the App Group.
public final class WatchBridgeSession: NSObject, ObservableObject, WCSessionDelegate {

    public static let shared = WatchBridgeSession()

    /// Last received key.
    @Published public private(set) var latestKey: String = "—"

    /// Last received JSON (raw string).
    @Published public private(set) var latestJson: String = "—"

    /// Info.plist key where the App Group ID is expected.
    private let appGroupPlistKey = "WatchBridgeAppGroupId"

    /// App Group ID read from the Info.plist (if available).
    private lazy var appGroupId: String? = {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: appGroupPlistKey) as? String else {
            return nil
        }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }()

    private override init() {
        super.init()
        activateSessionIfNeeded()
    }

    // MARK: - Session Setup

    private func activateSessionIfNeeded() {
        guard WCSession.isSupported() else { return }

        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    // MARK: - WCSessionDelegate

    public func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error = error {
            NSLog("WatchBridgeKit: activation failed: \(error)")
        } else {
            NSLog("WatchBridgeKit: activation state \(activationState.rawValue)")
        }
    }

    public func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        let key = applicationContext["key"] as? String ?? "unknown"
        let json = applicationContext["json"] as? String ?? ""

        NSLog("WatchBridgeKit: received context key=\(key), json=\(json)")

        // Optionally update the App Group if configured
        if let groupId = appGroupId,
            let defaults = UserDefaults(suiteName: groupId)
        {
            defaults.set(json, forKey: key)
            defaults.synchronize()
        }

        DispatchQueue.main.async {
            self.latestKey = key
            self.latestJson = json
        }
    }
}

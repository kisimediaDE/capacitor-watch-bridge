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
        guard WCSession.isSupported() else {
            NSLog("WatchBridgeKit: WCSession not supported on this device")
            return
        }

        let session = WCSession.default
        session.delegate = self
        session.activate()

        // Apply the last known application context at startup, if one exists.
        let initialContext = session.receivedApplicationContext
        if initialContext.isEmpty {
            NSLog(
                "WatchBridgeKit: no initial applicationContext (this is normal before first send)")
        } else {
            NSLog("WatchBridgeKit: applying initial applicationContext")
            applyContext(initialContext)
        }
    }

    // MARK: - Context Handling

    private func applyContext(_ context: [String: Any]) {
        guard let key = context["key"] as? String,
            let json = context["json"] as? String
        else {
            NSLog("WatchBridgeKit: applicationContext missing 'key' or 'json' → \(context)")
            return
        }

        NSLog("WatchBridgeKit: received context key=\(key), json=\(json)")

        // Optionally store the received JSON in the App Group if configured.
        if let groupId = appGroupId,
            let defaults = UserDefaults(suiteName: groupId)
        {
            defaults.set(json, forKey: key)
            defaults.synchronize()
        }

        // Update UI properties on the main thread.
        DispatchQueue.main.async {
            self.latestKey = key
            self.latestJson = json
        }
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

        // After activation, check again if an application context is now available.
        let context = session.receivedApplicationContext
        if context.isEmpty {
            NSLog("WatchBridgeKit: receivedApplicationContext still empty after activation")
        } else {
            NSLog("WatchBridgeKit: applying receivedApplicationContext after activation")
            applyContext(context)
        }
    }

    public func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        NSLog("WatchBridgeKit: didReceiveApplicationContext called")
        applyContext(applicationContext)
    }

    @available(watchOS, unavailable)
    public func sessionDidBecomeInactive(_ session: WCSession) {}

    @available(watchOS, unavailable)
    public func sessionDidDeactivate(_ session: WCSession) {}
}

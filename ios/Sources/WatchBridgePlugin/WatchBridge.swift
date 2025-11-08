import Foundation
import WatchConnectivity

enum WatchBridgeError: Error {
    case appGroupIdMissing
    case appGroupUserDefaultsUnavailable(String)
}

@objc public class WatchBridge: NSObject {

    /// Singleton-Instanz, damit es nur einen WCSession-Delegate gibt.
    public static let shared = WatchBridge()

    private override init() {
        super.init()
        setupSessionIfNeeded()
    }

    private var session: WCSession?

    // MARK: - WCSession Setup

    private func setupSessionIfNeeded() {
        guard WCSession.isSupported() else {
            session = nil
            return
        }

        let wcSession = WCSession.default
        wcSession.delegate = self
        wcSession.activate()
        session = wcSession
    }

    private func ensureSession() -> WCSession? {
        if let s = session {
            return s
        }
        setupSessionIfNeeded()
        return session
    }

    // MARK: - Public API

    /// Schreibt JSON in die App Group und versucht, es per WatchConnectivity zu schicken.
    @objc public func syncJson(appGroupId: String?, key: String, json: String) throws {
        // 1. App Group validieren
        guard let rawGroupId = appGroupId?.trimmingCharacters(in: .whitespacesAndNewlines),
            !rawGroupId.isEmpty
        else {
            throw WatchBridgeError.appGroupIdMissing
        }

        // 2. UserDefaults im App Group Container
        guard let defaults = UserDefaults(suiteName: rawGroupId) else {
            throw WatchBridgeError.appGroupUserDefaultsUnavailable(rawGroupId)
        }

        defaults.set(json, forKey: key)
        defaults.synchronize()

        // 3. Best-effort WatchConnectivity
        guard WCSession.isSupported() else { return }

        guard let activeSession = ensureSession() else {
            return
        }

        guard activeSession.isPaired, activeSession.isWatchAppInstalled else {
            NSLog(
                "WatchBridge: session isPaired=\(activeSession.isPaired), appInstalled=\(activeSession.isWatchAppInstalled)"
            )
            return
        }

        do {
            try activeSession.updateApplicationContext([
                "key": key,
                "json": json,
            ])
            NSLog("WatchBridge: sent application context for key=\(key)")
        } catch {
            NSLog("WatchBridge: Failed to update application context: \(error)")
        }
    }

    /// Liefert Availability-Infos als Dictionary für `call.resolve(...)`.
    @objc public func availability() -> [String: NSNumber] {
        guard WCSession.isSupported() else {
            return [
                "supported": false,
                "paired": false,
                "appInstalled": false,
            ].mapValues { NSNumber(value: $0) }
        }

        let wcSession = ensureSession()
        let paired = wcSession?.isPaired ?? false
        let installed = wcSession?.isWatchAppInstalled ?? false

        return [
            "supported": NSNumber(value: true),
            "paired": NSNumber(value: paired),
            "appInstalled": NSNumber(value: installed),
        ]
    }
}

// MARK: - WCSessionDelegate

extension WatchBridge: WCSessionDelegate {
    public func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error = error {
            NSLog("WatchBridge: WCSession activation failed: \(error)")
        } else {
            NSLog("WatchBridge: WCSession activated with state \(activationState.rawValue)")
        }
    }

    public func sessionDidBecomeInactive(_ session: WCSession) {
        // required by protocol, no-op
    }

    public func sessionDidDeactivate(_ session: WCSession) {
        // auf einem neuen Session-Objekt wieder aktivieren
        WCSession.default.activate()
    }

    public func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        // v1: iPhone → Watch only, eingehender Context wird ignoriert.
    }
}

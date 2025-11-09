// ios/Sources/WatchBridgePlugin/WatchBridge.swift
import Foundation
import WatchConnectivity

enum WatchBridgeError: Error {
    case appGroupIdMissing
    case appGroupUserDefaultsUnavailable(String)
}

@objc public class WatchBridge: NSObject {

    /// Singleton instance to ensure there is only one WCSession delegate.
    public static let shared = WatchBridge()

    private override init() {
        super.init()
        setupSessionIfNeeded()
    }

    private var session: WCSession?

    // MARK: - WCSession Setup

    /// Lazily sets up the WCSession if supported on this device.
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

    /// Returns the current WCSession, activating it if necessary.
    private func ensureSession() -> WCSession? {
        if let s = session {
            return s
        }
        setupSessionIfNeeded()
        return session
    }

    // MARK: - Public API

    /// Writes JSON into the shared App Group and tries to send it via WatchConnectivity.
    ///
    /// - Parameters:
    ///   - appGroupId: The App Group identifier (e.g. "group.com.example.myapp").
    ///   - key: The key under which the JSON string will be stored.
    ///   - json: The JSON string to store and sync.
    @objc public func syncJson(appGroupId: String?, key: String, json: String) throws {
        // 1. Validate App Group ID
        guard let rawGroupId = appGroupId?.trimmingCharacters(in: .whitespacesAndNewlines),
            !rawGroupId.isEmpty
        else {
            throw WatchBridgeError.appGroupIdMissing
        }

        // 2. Access UserDefaults in the App Group container
        guard let defaults = UserDefaults(suiteName: rawGroupId) else {
            throw WatchBridgeError.appGroupUserDefaultsUnavailable(rawGroupId)
        }

        defaults.set(json, forKey: key)
        defaults.synchronize()

        // 3. Best-effort WatchConnectivity sync
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

    /// Returns WatchConnectivity availability information as a dictionary
    /// suitable for `call.resolve(...)` on the Capacitor side.
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
        // Required by protocol, no-op for this implementation.
    }

    public func sessionDidDeactivate(_ session: WCSession) {
        // Re-activate the default session on the new session object.
        WCSession.default.activate()
    }

    public func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        // v1: iPhone → Watch only. Incoming context on iOS is ignored.
    }
}

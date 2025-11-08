//
//  WatchBridgeSession.swift
//  App
//
//  Created by Simon Kirchner on 09.11.25.
//

import Foundation
import WatchConnectivity
import Combine

class WatchBridgeSession: NSObject, ObservableObject, WCSessionDelegate {

    static let shared = WatchBridgeSession()

    @Published var latestKey: String = "—"
    @Published var latestJson: String = "—"

    private let appGroupId = "group.de.kisimedia.watchbridge"

    private override init() {
        super.init()
        activateSessionIfNeeded()
    }

    private func activateSessionIfNeeded() {
        guard WCSession.isSupported() else { return }

        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    // MARK: - WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error = error {
            NSLog("WatchBridge (watchOS): activation failed: \(error)")
        } else {
            NSLog("WatchBridge (watchOS): activation state \(activationState.rawValue)")
        }
    }

    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String : Any]
    ) {
        let key = applicationContext["key"] as? String ?? "unknown"
        let json = applicationContext["json"] as? String ?? ""

        NSLog("WatchBridge (watchOS): received context key=\(key), json=\(json)")

        // App Group optional mit befüllen
        if let defaults = UserDefaults(suiteName: appGroupId) {
            defaults.set(json, forKey: key)
            defaults.synchronize()
        }

        DispatchQueue.main.async {
            self.latestKey = key
            self.latestJson = json
        }
    }
}

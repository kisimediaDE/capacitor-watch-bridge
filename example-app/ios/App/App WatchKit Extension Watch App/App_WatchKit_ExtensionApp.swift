// App_WatchKit_ExtensionApp.swift
import SwiftUI
import WatchBridgeKit  // ✅ use the shared helper

@main
struct App_WatchKit_Extension_Watch_AppApp: App {
    @StateObject private var session = WatchBridgeSession.shared

    var body: some Scene {
        WindowGroup {
            VStack(spacing: 8) {
                Text("WatchBridge Debug")
                    .font(.headline)
                Text("Key: \(session.latestKey)")
                    .font(.footnote)
                Text("JSON:")
                    .font(.caption2)
                ScrollView {
                    Text(session.latestJson)
                        .font(.caption2)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding()
        }
    }
}

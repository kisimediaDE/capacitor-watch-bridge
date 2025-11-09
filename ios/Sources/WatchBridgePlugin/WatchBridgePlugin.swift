import Capacitor
import Foundation

/// WatchBridge iOS Plugin – thin wrapper around the WatchBridge helper.
///
/// JS: registerPlugin<WatchBridgePlugin>('WatchBridge', ...)
@objc(WatchBridgePlugin)
public class WatchBridgePlugin: CAPPlugin, CAPBridgedPlugin {

    public let identifier = "WatchBridge"
    public let jsName = "WatchBridge"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "syncJson", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "isAvailable", returnType: CAPPluginReturnPromise),
    ]

    /// App Group ID from capacitor.config:
    /// plugins: { WatchBridge: { appGroupId: "group.com.example.myapp" } }
    private var appGroupId: String? {
        // 1. Priority: capacitor.config (backwards compatible)
        if let value = getConfigValue("appGroupId") as? String {
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                return trimmed
            }
        }

        // 2. Fallback: Info.plist / WatchBridgeAppGroupId
        if let plistValue = Bundle.main.object(forInfoDictionaryKey: "WatchBridgeAppGroupId")
            as? String
        {
            let trimmed = plistValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                return trimmed
            }
        }

        return nil
    }

    // MARK: - JS API

    /// syncJson(options: { key: string, json: string })
    @objc func syncJson(_ call: CAPPluginCall) {
        guard let key = call.getString("key"), !key.isEmpty else {
            call.reject("Missing 'key' option")
            return
        }

        guard let json = call.getString("json") else {
            call.reject("Missing 'json' option")
            return
        }

        do {
            try WatchBridge.shared.syncJson(appGroupId: appGroupId, key: key, json: json)
            call.resolve()
        } catch WatchBridgeError.appGroupIdMissing {
            call.reject(
                "App Group ID not configured. Please set 'plugins.WatchBridge.appGroupId' in capacitor.config or 'WatchBridgeAppGroupId' in Info.plist."
            )
        } catch WatchBridgeError.appGroupUserDefaultsUnavailable(let groupId) {
            call.reject("Unable to open UserDefaults for app group '\(groupId)'.")
        } catch {
            call.reject("Unknown error in syncJson: \(error.localizedDescription)")
        }
    }

    /// isAvailable(): Promise<{ supported, paired, appInstalled }>
    @objc func isAvailable(_ call: CAPPluginCall) {
        let info = WatchBridge.shared.availability()
        call.resolve(info)
    }
}

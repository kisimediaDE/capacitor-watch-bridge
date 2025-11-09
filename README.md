# ⌚️ capacitor-watch-bridge

> A modern, generic JSON bridge between a Capacitor iOS app and a native watchOS app  
> using **WatchConnectivity** and **App Groups** — built with Capacitor 7 & Swift 5.9.

---

<p align="center">
  <a href="https://www.npmjs.com/package/capacitor-watch-bridge">
    <img src="https://img.shields.io/npm/v/capacitor-watch-bridge?color=007aff&style=flat-square" alt="npm version" />
  </a>
  <a href="https://www.npmjs.com/package/capacitor-watch-bridge">
    <img src="https://img.shields.io/npm/dw/capacitor-watch-bridge?style=flat-square" alt="downloads" />
  </a>
  <a href="https://capacitorjs.com">
    <img src="https://img.shields.io/badge/Capacitor-7.0-blue?style=flat-square" alt="Capacitor 7" />
  </a>
</p>

---

## 🚀 Features

✅ Sync arbitrary JSON data from iOS → watchOS via `updateApplicationContext()`  
✅ Store the same data in a shared **App Group** for offline access  
✅ Gracefully degrades if no Watch is paired or the app isn’t installed  
✅ Fully written in Swift 5.9 with Swift Package Manager support (CocoaPods spec included)  
✅ Drop-in Capacitor 7 plugin – zero additional configuration on web

---

## 📦 Installation

```bash
npm install capacitor-watch-bridge
npx cap sync
```

---

## ⚙️ Configuration

Add your App Group ID to the Capacitor config:

```typescript
// capacitor.config.ts or capacitor.config.json
plugins: {
  WatchBridge: {
    appGroupId: 'group.de.kisimedia.watchbridge',
  },
},
```

Make sure the same App Group is enabled under
`Xcode → Signing & Capabilities → App Groups`
for both your iOS app and the WatchKit Extension.

---

### 🧠 Usage

```typescript
import { WatchBridge } from 'capacitor-watch-bridge';

await WatchBridge.syncJson({
  key: 'tasks',
  json: JSON.stringify([{ id: 1, title: 'Buy coffee beans ☕️' }]),
});

const info = await WatchBridge.isAvailable();
console.log('Watch status:', info);
```

On the watch, use the helper `WatchBridgeSession` to listen for new data
and read from your App Group:

```swift
import WatchConnectivity

final class MySession: NSObject, WCSessionDelegate {
  func session(_ session: WCSession,
               didReceiveApplicationContext context: [String : Any]) {
      if let json = context["json"] as? String {
          print("Received JSON:", json)
      }
  }
}
```

---

### 🧩 Example App

A minimal Capacitor 7 + Vite demo is included under example-app/
with a modern, app-like HTML UI for testing iPhone ↔ Watch communication.

| iPhone Demo                                                        | Watch Demo                                                             |
| ------------------------------------------------------------------ | ---------------------------------------------------------------------- |
| <img src="demo-screenshot-light.png" width="300" alt="iOS Demo" /> | <img src="demo-screenshot-watch.png" width="300" alt="watchOS Demo" /> |

---

## API

<docgen-index>

- [`syncJson(...)`](#syncjson)
- [`isAvailable()`](#isavailable)
- [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

Public API of the WatchBridge plugin.

### syncJson(...)

```typescript
syncJson(options: SyncJsonOptions) => Promise<void>
```

Stores a JSON string in the configured App Group and tries
to sync it to the watchOS app via WatchConnectivity.

If no watch is paired or available, the data is still written
to the App Group and the Promise resolves without error.

| Param         | Type                                                        |
| ------------- | ----------------------------------------------------------- |
| **`options`** | <code><a href="#syncjsonoptions">SyncJsonOptions</a></code> |

---

### isAvailable()

```typescript
isAvailable() => Promise<IsAvailableResult>
```

Returns information about WatchConnectivity availability:

- if it is supported
- if a watch is paired
- if the watchOS app is installed

**Returns:** <code>Promise&lt;<a href="#isavailableresult">IsAvailableResult</a>&gt;</code>

---

### Interfaces

#### SyncJsonOptions

| Prop       | Type                | Description                                                                              |
| ---------- | ------------------- | ---------------------------------------------------------------------------------------- |
| **`key`**  | <code>string</code> | Key under which the data is stored in the shared App Group. Example: "items" or "tasks". |
| **`json`** | <code>string</code> | JSON string provided by the app. The plugin does not validate or parse this string.      |

#### IsAvailableResult

| Prop               | Type                 | Description                                                        |
| ------------------ | -------------------- | ------------------------------------------------------------------ |
| **`supported`**    | <code>boolean</code> | True if WatchConnectivity (WCSession) is supported on this device. |
| **`paired`**       | <code>boolean</code> | True if an Apple Watch is paired with the iPhone.                  |
| **`appInstalled`** | <code>boolean</code> | True if the watchOS companion app is installed.                    |

</docgen-api>

---

### 🧰 Requirements

- iOS 14+ / watchOS 7+ (tested with iOS 18 / watchOS 11)
- Capacitor 7.0+
- Swift 5.9+
- Xcode 15+

---

### 🧑‍💻 Author

Made with ❤️ by Kisimedia
for open-source Capacitor developers everywhere.

---

### 🪲 Known Limitations

- Android not implemented (stub only)
- Plugin does not validate JSON syntax
- No bi-directional sync yet (watch → iPhone planned for v2)

---

### 📝 License

MIT © Kisimedia.de

See LICENSE for details.

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

👉 GitHub: [github.com/kisimediaDE/capacitor-watch-bridge](https://github.com/kisimediaDE/capacitor-watch-bridge)

---

## 📚 Table of Contents

<!-- toc -->

- [🚀 What you get](#%F0%9F%9A%80-what-you-get)
- [📦 Installation](#%F0%9F%93%A6-installation)
  * [1. Install the Capacitor plugin](#1-install-the-capacitor-plugin)
  * [2. Add WatchBridgeKit to your watchOS target (SPM)](#2-add-watchbridgekit-to-your-watchos-target-spm)
- [⚙️ Configuration](#%E2%9A%99%EF%B8%8F-configuration)
- [🧠 Usage](#%F0%9F%A7%A0-usage)
- [🧩 Example App](#%F0%9F%A7%A9-example-app)
- [API](#api)
  * [syncJson(...)](#syncjson)
  * [isAvailable()](#isavailable)
  * [Interfaces](#interfaces)
    + [SyncJsonOptions](#syncjsonoptions)
    + [IsAvailableResult](#isavailableresult)
- [🧰 Requirements](#%F0%9F%A7%B0-requirements)
- [🧑‍💻 Author](#%F0%9F%A7%91%E2%80%8D%F0%9F%92%BB-author)
- [🪲 Known Limitations](#%F0%9F%AA%B2-known-limitations)
- [📝 License](#%F0%9F%93%9D-license)

<!-- tocstop -->

---

## 🚀 What you get

This package contains **two** Swift targets:

1. **`WatchBridgePlugin`** – the Capacitor iOS plugin (used in your iPhone app)
2. **`WatchBridgeKit`** – a tiny **watchOS helper framework** that:
   - wraps `WCSession` on the watch
   - reads the App Group ID from `WatchBridgeAppGroupId` in the watch Info.plist
   - exposes `@Published` properties `latestKey` and `latestJson` for your UI

High-level features:

✅ Sync arbitrary JSON from iOS → watchOS via `updateApplicationContext()`  
✅ Store the same data in a shared **App Group** for offline access  
✅ Gracefully degrades if no Watch is paired or the app isn’t installed  
✅ Swift Package Manager **and** CocoaPods support  
✅ Drop-in Capacitor 7 plugin – zero additional configuration on web

---

## 📦 Installation

### 1. Install the Capacitor plugin

```bash
npm install capacitor-watch-bridge
npx cap sync ios
```

Capacitor will add the iOS plugin (CapacitorWatchBridge) to your Podfile automatically.

### 2. Add WatchBridgeKit to your watchOS target (SPM)

In Xcode:

1. File → Add Packages…
2. Enter the repo URL:
   ```text
   https://github.com/kisimediaDE/capacitor-watch-bridge.git
   ```
3. Add the following products:
   - "CapacitorWatchBridge" → iOS app target (if you also use SPM directly)
   - "WatchBridgeKit" → WatchKit Extension target

The repo already ships a Package.swift with:

```swift
products: [
    .library(name: "CapacitorWatchBridge", targets: ["WatchBridgePlugin"]),
    .library(name: "WatchBridgeKit", targets: ["WatchBridgeKit"]),
]
```

---

## ⚙️ Configuration

1. **Configure your App Group (iOS + watchOS)**

   Create an App Group, e.g.:

   ```text
   group.de.kisimedia.watchbridge
   ```

   Then enable this group under Signing & Capabilities → App Groups for:
   - the iOS App target
   - the WatchKit Extension target

2. **Capacitor config (iOS app)**

   ```typescript
   // capacitor.config.ts / capacitor.config.json
   export default {
     // ...
     plugins: {
       WatchBridge: {
         appGroupId: 'group.de.kisimedia.watchbridge',
       },
     },
   };
   ```

   On iOS the plugin:
   1. First tries plugins.WatchBridge.appGroupId from capacitor.config.
   2. Falls back to the Info.plist key WatchBridgeAppGroupId (see below).

3. **Info.plist key (watchOS and optional iOS fallback)**

   **_WatchKit Extension Info.plist_**

   ```xml
   <key>WatchBridgeAppGroupId</key>
   <string>group.de.kisimedia.watchbridge</string>
   ```

   This is what WatchBridgeKit uses to know which App Group to write into.

   **_Optional: iOS App Info.plist_**

   If you don’t want to configure the App Group in capacitor.config, you can also
   set the same key in your iOS app’s Info.plist and skip the plugin config:

   ```xml
   <key>WatchBridgeAppGroupId</key>
   <string>group.de.kisimedia.watchbridge</string>
   ```

---

## 🧠 Usage

1. **From Capacitor (iOS / web)**

   ```typescript
   import { WatchBridge } from 'capacitor-watch-bridge';

   await WatchBridge.syncJson({
     key: 'debugText',
     json: JSON.stringify({ text: 'Hello from Capacitor!' }),
   });

   const info = await WatchBridge.isAvailable();
   console.log('Watch status:', info);
   ```

2. **On watchOS with WatchBridgeKit**

   **_SwiftUI example_**

   ```swift
     import SwiftUI
     import WatchBridgeKit

     @main
     struct MyWatchApp: App {
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
   ```

   WatchBridgeSession will:
   - activate the WCSession once
   - apply any previously known applicationContext on startup
   - listen for new contexts via didReceiveApplicationContext
   - optionally write the JSON into your App Group UserDefaults(suiteName:)

   **_Non-SwiftUI / manual access_**

   You can also use it without SwiftUI:

   ```swift
   import WatchBridgeKit

   let session = WatchBridgeSession.shared
   // Access session.latestKey / session.latestJson
   // or subscribe via Combine: session.$latestJson.sink { ... }
   ```

---

## 🧩 Example App

A minimal Capacitor 7 + Vite demo is included under example-app/.

It ships a full working setup:

- iOS app with the Capacitor plugin
- watchOS app using WatchBridgeKit
- both targets sharing the App Group
- a small HTML UI that shows connectivity state & sends JSON to the watch

| iPhone Demo                                                        | Watch Demo                                                             |
| ------------------------------------------------------------------ | ---------------------------------------------------------------------- |
| <img src="demo-screenshot-light.png" width="300" alt="iOS Demo" /> | <img src="demo-screenshot-watch.png" width="300" alt="watchOS Demo" /> |

To run it:

```bash
cd example-app
npm install
npx cap sync ios
npx cap open ios
```

The example already uses:

- App Group: group.de.kisimedia.watchbridge
- WatchBridgeKit in the WatchKit Extension
- WatchBridgeSession as shown above

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

## 🧰 Requirements

- iOS 14+
- watchOS 10+ (for WatchBridgeKit as defined in Package.swift)
- Capacitor 7.0+
- Swift 5.9+
- Xcode 15+

---

## 🧑‍💻 Author

Made with ❤️ by Kisimedia
for open-source Capacitor developers everywhere.

---

## 🪲 Known Limitations

- Android not implemented (stub only)
- Plugin does not validate JSON syntax
- No bi-directional sync yet (watch → iPhone planned for v2)

---

## 📝 License

MIT © Kisimedia.de

See LICENSE for details.

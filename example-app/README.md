# 📱 Example App – Capacitor Watch Bridge

This example demonstrates how to sync JSON data between  
a Capacitor iOS app and a native **watchOS app** using  
[`capacitor-watch-bridge`](../README.md) and **WatchConnectivity**.

It includes:
- an iOS app using the **WatchBridge Capacitor plugin**
- a watchOS app using the **WatchBridgeKit** framework
- a shared **App Group** for local JSON persistence

---

## ⚙️ Setup

1. **Install and link the plugin**

   ```bash
   npm install
   npx cap sync ios
    ```

2. **Open the example app in Xcode**

    ```bash
    npx cap open ios
    ```

3. **Enable the App Group for both the iOS app and the WatchKit Extension:**
    > 💡 The included WatchKit Extension and iOS App already share the same App Group ID: ***group.de.kisimedia.watchbridge***

---

## 🧠 What this demo shows

✅ iOS → watchOS JSON sync via \`updateApplicationContext()\`

✅ Shared App Group storage using \`UserDefaults(suiteName:)\`

✅ Live status display of watch connectivity in the web UI

✅ SwiftUI interface on watchOS powered by WatchBridgeKit

✅ Minimal Capacitor + Vite web app styled like a native iPhone UI

---

## ⌚️ WatchBridgeKit overview

The included watch app demonstrates usage of WatchBridgeKit —
a helper framework that activates a WCSession, listens for
incoming applicationContext updates, and writes them to
a shared App Group.

**Core logic:**
```swift
import WatchBridgeKit

@main
struct App_WatchKit_Extension_Watch_AppApp: App {
    @StateObject private var session = WatchBridgeSession.shared

    var body: some Scene {
        WindowGroup {
            VStack(spacing: 8) {
                Text("WatchBridge Debug").font(.headline)
                Text("Key: \(session.latestKey)").font(.footnote)
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

---


## 🕹️ Run in the browser
You can also run the web demo (without native watch features):

```bash
npm start
```

Then open:
👉 http://localhost:5173


---

## 🧩 UI Preview
<p align="center"> <img src="../demo-screenshot-light.png" width="45%" alt="iOS Demo UI" style="margin-right:2%;" /> <img src="../demo-screenshot-watch.png" width="45%" alt="watchOS Demo UI" /> </p>

---

## 🛠️ Stack
- Capacitor 7
- Vite
- Swift 5.9
- WatchConnectivity
- WatchBridgeKit

---

## 🧑‍💻 Author
Built with ❤️ by Kisimedia
for testing and development of the capacitor-watch-bridge plugin.
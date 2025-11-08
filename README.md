# capacitor-watch-bridge

A generic JSON sync bridge between a Capacitor iOS app and a native watchOS app using WatchConnectivity and App Groups.

## Install

```bash
npm install capacitor-watch-bridge
npx cap sync
```

## API

<docgen-index>

* [`syncJson(...)`](#syncjson)
* [`isAvailable()`](#isavailable)
* [Interfaces](#interfaces)

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

--------------------


### isAvailable()

```typescript
isAvailable() => Promise<IsAvailableResult>
```

Returns information about WatchConnectivity availability:
- if it is supported
- if a watch is paired
- if the watchOS app is installed

**Returns:** <code>Promise&lt;<a href="#isavailableresult">IsAvailableResult</a>&gt;</code>

--------------------


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

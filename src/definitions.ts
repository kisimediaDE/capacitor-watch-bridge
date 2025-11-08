export interface SyncJsonOptions {
  /**
   * Key under which the data is stored in the shared App Group.
   * Example: "items" or "tasks".
   */
  key: string;

  /**
   * JSON string provided by the app.
   * The plugin does not validate or parse this string.
   */
  json: string;
}

export interface IsAvailableResult {
  /**
   * True if WatchConnectivity (WCSession) is supported on this device.
   */
  supported: boolean;

  /**
   * True if an Apple Watch is paired with the iPhone.
   */
  paired: boolean;

  /**
   * True if the watchOS companion app is installed.
   */
  appInstalled: boolean;
}

/**
 * Public API of the WatchBridge plugin.
 */
export interface WatchBridgePlugin {
  /**
   * Stores a JSON string in the configured App Group and tries
   * to sync it to the watchOS app via WatchConnectivity.
   *
   * If no watch is paired or available, the data is still written
   * to the App Group and the Promise resolves without error.
   */
  syncJson(options: SyncJsonOptions): Promise<void>;

  /**
   * Returns information about WatchConnectivity availability:
   * - if it is supported
   * - if a watch is paired
   * - if the watchOS app is installed
   */
  isAvailable(): Promise<IsAvailableResult>;
}

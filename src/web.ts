import { WebPlugin } from '@capacitor/core';

import type { WatchBridgePlugin, SyncJsonOptions, IsAvailableResult } from './definitions';

export class WatchBridgeWeb extends WebPlugin implements WatchBridgePlugin {
  async syncJson(options: SyncJsonOptions): Promise<void> {
    // Optional: store data locally for debugging on web
    try {
      if (typeof window !== 'undefined' && 'localStorage' in window) {
        window.localStorage.setItem(`watchbridge:${options.key}`, options.json);
      }
    } catch {
      // ignore storage errors on web
    }
  }

  async isAvailable(): Promise<IsAvailableResult> {
    // Web has no WatchConnectivity, so we always return "not available"
    return {
      supported: false,
      paired: false,
      appInstalled: false,
    };
  }
}

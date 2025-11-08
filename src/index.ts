import { registerPlugin } from '@capacitor/core';

import type { WatchBridgePlugin } from './definitions';

export const WatchBridge = registerPlugin<WatchBridgePlugin>('WatchBridge', {
  web: () => import('./web').then((m) => new m.WatchBridgeWeb()),
});

export * from './definitions';

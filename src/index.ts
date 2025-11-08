import { registerPlugin } from '@capacitor/core';

import type { WatchBridgePluginPlugin } from './definitions';

const WatchBridgePlugin = registerPlugin<WatchBridgePluginPlugin>('WatchBridgePlugin', {
  web: () => import('./web').then((m) => new m.WatchBridgePluginWeb()),
});

export * from './definitions';
export { WatchBridgePlugin };

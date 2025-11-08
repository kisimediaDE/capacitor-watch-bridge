import { WebPlugin } from '@capacitor/core';

import type { WatchBridgePluginPlugin } from './definitions';

export class WatchBridgePluginWeb extends WebPlugin implements WatchBridgePluginPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}

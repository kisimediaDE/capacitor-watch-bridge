export interface WatchBridgePluginPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}

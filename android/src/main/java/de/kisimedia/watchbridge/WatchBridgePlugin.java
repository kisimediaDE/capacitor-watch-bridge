package de.kisimedia.watchbridge;

import com.getcapacitor.Logger;

public class WatchBridgePlugin {

    public String echo(String value) {
        Logger.info("Echo", value);
        return value;
    }
}

import { WatchBridgePlugin } from 'capacitor-watch-bridge';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    WatchBridgePlugin.echo({ value: inputValue })
}

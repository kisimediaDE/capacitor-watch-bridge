import { WatchBridge } from 'capacitor-watch-bridge';

window.testEcho = async () => {
  const inputValue = document.getElementById("echoInput").value;

  // Beispiel: syncJson mit einem kleinen JSON-Objekt
  await WatchBridge.syncJson({
    key: 'debugText',
    json: JSON.stringify({ text: inputValue }),
  });

  // Optional: Verfügbarkeit loggen
  const info = await WatchBridge.isAvailable();
  console.log('Watch availability:', info);
};
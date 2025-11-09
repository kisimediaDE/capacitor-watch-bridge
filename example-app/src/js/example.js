
import { WatchBridge } from 'capacitor-watch-bridge';

const input = document.getElementById('echoInput');
const sendBtn = document.getElementById('sendBtn');
const statusBox = document.getElementById('statusBox');

async function refreshAvailability() {
  const info = await WatchBridge.isAvailable();
  statusBox.innerHTML = `
    <strong>WatchConnectivity:</strong><br>
    Supported: ${info.supported ? '✅' : '❌'}<br>
    Paired: ${info.paired ? '⌚️' : '—'}<br>
    App Installed: ${info.appInstalled ? '📲' : '—'}
  `;
}

async function sendJson() {
  const text = input.value.trim();
  if (!text) return;
  await WatchBridge.syncJson({
    key: 'debugText',
    json: JSON.stringify({ text }),
  });
  sendBtn.innerText = '✅ Sent!';
  setTimeout(() => (sendBtn.innerText = 'Send to Watch'), 1200);
  refreshAvailability();
}

sendBtn.addEventListener('click', sendJson);
document.addEventListener('DOMContentLoaded', refreshAvailability);
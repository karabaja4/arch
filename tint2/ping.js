const WebSocket = require('ws');
const disk = require('diskusage');
const timers = require('timers/promises');

let diskusage = null;

const refresh = async () => {
  while (true) {
    try {
      if (diskusage == null || (diskusage.ts + (30 * 1000)) < Date.now()) {
        const info = await disk.check('/');
        const total = info.total / 1024;
        const available = info.available / 1024;
        const used = total - available - (321121 * 4) - 16384;
        diskusage = { total, available, used, ts: Date.now() }
        console.log(`Fetched disk usage: ${JSON.stringify(diskusage)}`)
      }
    } catch (e) {
      console.log(e);
    }
    await timers.setTimeout(10 * 1000);
  }
}

const server = () => {
  const wss = new WebSocket.Server({
    port: 32713,
    maxPayload: 1024
  });
  wss.on('connection', (ws) => {
    ws.on('message', (message) => {
      const response = JSON.stringify({
        message: message,
        diskusage: diskusage
      });
      ws.send(response);
    });
  });
}

refresh();
server();

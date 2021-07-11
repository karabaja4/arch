const WebSocket = require('ws');
const disk = require('diskusage');
const timers = require('timers/promises');

let diskusage = null;

const refresh = async () => {
  try {
    const info = await disk.check('/');
    const total = info.total / 1024;
    const available = info.available / 1024;
    const used = total - available - (321121 * 4) - 16384;
    diskusage = { total, available, used, ts: Date.now() };
    console.log(`Fetched disk usage: ${JSON.stringify(diskusage)}`);
  } catch (e) {
    console.log(e);
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

const main = async () => {
  await refresh();
  server();
  while (true) {
    await timers.setTimeout(30 * 1000);
    await refresh();
  }
}

main();

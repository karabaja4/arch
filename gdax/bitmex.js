const fs = require('fs');
const WebSocket = require('ws');

const green = '#69F0AE';
const red = '#FF6E40';

const connect = () => {
  const ws = new WebSocket('wss://www.bitmex.com/realtime');
  ws.on('open', () => {
    const instrument = JSON.stringify({ op: 'subscribe', args: 'instrument:XBTUSD' });
    ws.send(instrument);
  });
  
  ws.on('message', async (data) => {
    try {
      const parsed = JSON.parse(data);
      if (parsed.table == 'instrument' && parsed.action == 'update') {
        const info = parsed.data[0];
        if (info && info.lastPrice) {
          const direction = info.lastTickDirection == 'ZeroPlusTick' || info.lastTickDirection == 'PlusTick' ? 1 : -1;
          const color = direction == 1 ? green : red;
          const price = parseInt(info.lastPrice);
          const text = `${price} USD`;
          console.log(`${color} ${text}`);
          await fs.promises.writeFile('/tmp/btctrend', color);
          await fs.promises.writeFile('/tmp/btcconky', text);
        }
      }
    } catch (e) {
      console.log(e);
    }
  });

  ws.on('close', () => {
    console.log('closed, reconnecting...');
    setTimeout(connect, 1000);
  });
};

connect();
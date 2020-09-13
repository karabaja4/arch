const WebSocket = require('ws');
const rs = require('randomstring');

const events = {};

const isDataObject = (o) => {
  return o.p &&
    Array.isArray(o.p) &&
    o.p[1] &&
    o.p[1]['n'] &&
    o.p[1]['s'] &&
    o.p[1]['v'] &&
    o.p[1]['v']['lp'];
}

const process = async (message) => {
  const parts = message.split('~m~');
  for (let i = 0; i < parts.length; i++) {
    const p = parts[i];
    const match = p.match(/{.+}/g);
    if (match) {
      try {
        const parsed = JSON.parse(match[0]);
        if (isDataObject(parsed)) {
          const name = parsed.p[1]['n'];
          const price = parsed.p[1]['v']['lp'];
          const change = parsed.p[1]['v']['ch'];
          const percent = parsed.p[1]['v']['chp'];
          if (events.receive) {
            events.receive(name, { price: price, change: change, percent: percent });
          }
        }
      } catch (e) {
        if (events.error) {
          events.error(e);
        }
      }
    }
  }
}

const connect = (symbols) => {

  const ws = new WebSocket('wss://data.tradingview.com/socket.io/websocket', {
    origin: 'https://www.tradingview.com'
  });

  const timer = setTimeout(() => { // timeout
    ws.terminate();
  }, 20000);

  ws.on('open', () => {
    //console.log('open');
  });

  ws.on('message', (message) => {
    timer.refresh();
    if (message.includes('session_id')) {
      const sid = `qs_${rs.generate(12)}`;
      const messages = [
        `~m~52~m~{"m":"quote_create_session","p":["${sid}"]}`,
        `~m~313~m~{"m":"quote_add_symbols","p":["${sid}","${symbols.join('","')}",{"flags":["force_permission"]}]}`
      ];
      messages.forEach(m => ws.send(m));
    } else {
      if (message.match(/^~m~\d+~m~~h~\d+$/g)) { // ping
        ws.send(message);
        //console.log('pong');
      } else {
        process(message);
      }
    }
  });

  ws.on('error', (e) => {
    if (events.error) {
      events.error(e);
    }
  });

  ws.on('close', (code) => {
    if (events.close) {
      events.close(code);
    }
    setTimeout(() => connect(symbols), 5000);
  });

};

const init = (symbols) => {
  connect(symbols);
}

const on = (name, callback) => {
  events[name] = callback;
}

module.exports = {
  init,
  on
};
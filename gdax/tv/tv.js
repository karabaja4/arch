
const wsc = require('websocket').client;
const ws = new wsc();
const rs = require('randomstring');

const symbols = [
  'BITMEX:XBTUSD',
  'TVC:USOIL',
  'TVC:DXY',
  'FOREXCOM:NSXUSD',
  'TVC:SPX',
  'CURRENCYCOM:GOLD',
  'WHSELFINVEST:JAPAN225CFD',
  'FX:EURUSD',
  'FX:AUDUSD',
  'TVC:VIX',
  'TVC:UKOIL',
  'NASDAQ:DOCU',
  'NASDAQ:TSLA',
  'NASDAQ:NVDA',
  'NASDAQ:AAPL',
  'NYSE:CRM'
];

const isDataObject = (obj) => {
  return obj.p && 
         Array.isArray(obj.p) &&
         obj.p[1] && 
         obj.p[1]['n'] && 
         obj.p[1]['s'] && 
         obj.p[1]['v'] && 
         obj.p[1]['v']['lp'];
}

const process = (message, conn) => {
  const sessionId = `qs_${rs.generate(12)}`;
  if (message.includes('session_id')) {
    conn.sendUTF(`~m~52~m~{"m":"quote_create_session","p":["${sessionId}"]}`);
    conn.sendUTF(`~m~305~m~{"m":"quote_add_symbols","p":["${sessionId}","${symbols.join('","')}",{"flags":["force_permission"]}]}`);
  } else {
    if (message.match(/^~m~\d+~m~~h~\d+$/g)) {
      conn.sendUTF(message);
      console.log('pong');
    } else {
      const parts = message.split('~m~');
      parts.forEach(x => {
        const match = x.match(/{.+}/g);
        if (match) {
          try {
            const parsed = JSON.parse(match[0]);
            if (isDataObject(parsed)) {
              const name = parsed.p[1]['n'];
              const price = parsed.p[1]['v']['lp'];
              const change = parsed.p[1]['v']['ch'];
              const percent = parsed.p[1]['v']['chp'];

              console.log(`${name} -> PRICE: ${price}, ${change ? `CHANGE: ${change}, ` : ''}${percent ? `PERCENT: ${percent}%` : ''}`);
            }
          } catch(e) {
            console.log(`error parsing json: ${match[0]}`);
            console.log(e);
          }
        }
      });
    }
  }
}

ws.on('connect', (conn) => {
  conn.on('close', () => {
    console.log('close');
  });
  conn.on('message', (message) => {
    if (conn.connected) {
      process(message.utf8Data, conn);
    }
  });
})

ws.connect('wss://data.tradingview.com/socket.io/websocket', null, 'https://www.tradingview.com');

const WebSocket = require('ws');
const rs = require('randomstring');

const sym = [
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

const isDataObject = (o) => {
  return o.p && 
         Array.isArray(o.p) &&
         o.p[1] && 
         o.p[1]['n'] && 
         o.p[1]['s'] && 
         o.p[1]['v'] && 
         o.p[1]['v']['lp'];
}

const process = (message) => {
  const parts = message.split('~m~');
  parts.forEach(p => {
    const match = p.match(/{.+}/g);
    if (match) {
      try {
        const parsed = JSON.parse(match[0]);
        if (isDataObject(parsed)) {
          const name = parsed.p[1]['n'];
          const price = parsed.p[1]['v']['lp'];
          const change = parsed.p[1]['v']['ch'];
          const percent = parsed.p[1]['v']['chp'];
          console.log(`${name} -> PRICE: ${price}${change ? `, CHANGE: ${change}` : ''}${percent ? `, PERCENT: ${percent}%` : ''}`);
        }
      } catch(e) {
        console.log(`error parsing json: ${match[0]}`);
        console.log(e);
      }
    }
  });
}

const connect = () => {

  const ws = new WebSocket('wss://data.tradingview.com/socket.io/websocket', {
    origin: 'https://www.tradingview.com'
  });

  ws.on('open', () => {
    console.log('open');
  });
  
  ws.on('message', (message) => {
    if (message.includes('session_id')) {
      const sid = `qs_${rs.generate(12)}`;
      const messages = [
        `~m~52~m~{"m":"quote_create_session","p":["${sid}"]}`,
        `~m~305~m~{"m":"quote_add_symbols","p":["${sid}","${sym.join('","')}",{"flags":["force_permission"]}]}`
      ];
      messages.forEach(m => ws.send(m));
    } else {
      if (message.match(/^~m~\d+~m~~h~\d+$/g)) { // ping
        ws.send(message);
        console.log('pong');
      } else {
        process(message);
      }
    }
  });

  ws.on('error', () => {
    console.log('socket error');
  });

  ws.on('close', () => {
    console.log('closed, reconnecting...');
    setTimeout(connect, 5000);
  });

};

connect();
const fs = require('fs');
const util = require('util');
const sleep = util.promisify(setTimeout);
const symbols = require('../trade/symbols.json').symbols;
const ws = require('../trade/lib/ws.js');

const files = {
  conky: '/tmp/conky_data.json'
}

const colors = {
  gray: '#757575',
  red: '#FF6E40',
  yellow: '#EEFF41',
  green: '#69F0AE'
};

const icons = {
  netdown: '',
  netup: '',
  cpu: '',
  mem: '',
  ssd: '',
  mmc: '',
  edd: '',
  trenddown: '',
  trendup: '',
  clock: ''
};

const span = (size, rise, color, icon, text) => {
  return `<span font_family="Flaticon" size="${size}" rise="${rise}" foreground="${color}">${icon}</span>  ${text}         `;
};

const nc = (value) => {
  if (value === null || value === undefined) return colors.gray;
  if (value > 5) return colors.green;
  return colors.gray;
};

const oc = (value) => {
  if (value === null || value === undefined) return colors.gray;
  if (value > 80) return colors.red;
  if (value > 30) return colors.yellow;
  return colors.green;
};

const fixunits = (unit) => {
  return unit.replace('GiB', 'GB').replace('MiB', 'MB').replace('KiB', 'KB');
};

const process = async (json) => {
  const data = JSON.parse(json);
  let text = '';

  text += span(8000, 100, nc(data.net.down), icons.netdown, `DWL: ${data.net.down} KB`);
  text += span(8000, 100, nc(data.net.up), icons.netup, `UPL: ${data.net.up} KB`);
  text += span(5000, 1200, oc(data.cpu.perc), icons.cpu, `CPU: ${data.cpu.perc}% (${data.cpu.freq} MHz)`);
  text += span(8000, 100, oc(data.mem.perc), icons.mem, `RAM: ${fixunits(data.mem.used)} / ${fixunits(data.mem.max)}`);

  const disktext = (name) => `${name.toUpperCase()}: ${data[name] ? `${fixunits(data[name].used)} / ${fixunits(data[name].size)}` : 'not mounted'}`;
  const diskspan = (name) => span(8000, 100, oc(data[name]?.perc), icons[name], disktext(name));

  text += diskspan('ssd');
  text += diskspan('mmc');
  text += diskspan('edd');

  // trade
  const td = getTradeData();
  if (td) {
    const tc = td.trend ? colors.green : colors.red;
    const ti = td.trend ? icons.trendup : icons.trenddown;
    text += span(8000, -400, tc, ti, td.text);
  } else {
    text += span(8000, -400, colors.gray, icons.trenddown, 'TRA: not connected');
  }

  text += span(8000, 100, colors.gray, icons.clock, `CLK: ${data.time}`).trimEnd();
  console.log(text);
};

const tradeStore = {};
const tradeSymbol = 'FOREXCOM:NSXUSD';

const getTradeData = () => {
  const values = tradeStore[tradeSymbol];
  if (values) {
    const price = values['price'];
    const change = values['change'];
    const namePrint = tradeSymbol.split(':')[1].replace('USD', '');
    const pricePrint = `${price.toFixed(2)} USD`;
    const changePrint = `${change > 0 ? '+' : ''}${change.toFixed(2)} USD`;
    return {
      text: `${namePrint}: ${pricePrint} | ${changePrint}`,
      trend: change > 0
    }
  }
  return null;
}

ws.on('receive', (name, feed) => {
  if (!tradeStore[name]) tradeStore[name] = {};
  if (feed.price !== undefined) tradeStore[name]['price'] = feed.price;
  if (feed.change !== undefined) tradeStore[name]['change'] = feed.change;
  if (feed.percent !== undefined) tradeStore[name]['percent'] = feed.percent;
});

const main = async () => {
  ws.init(symbols);
  while (true) {
    try {
      const json = (await fs.promises.readFile(files.conky)).toString();
      if (json && json.trim()) {
        await process(json);
      }
    } catch (e) {
      console.log(e);
    }
    await sleep(1000);
  }
};

main();

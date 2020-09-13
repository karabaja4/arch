const ws = require('./lib/ws');
const plasma = require('./lib/plasma');
const conky = require('./lib/conky');
const symbols = require('./symbols.json').symbols;
const args = require('minimist')(process.argv.slice(2));

const mode = {
  plasma: !!args['plasma'],
  conky: !!args['conky'],
};

if ((!mode.conky && !mode.plasma) || (mode.conky && mode.plasma)) {
  console.log('requires one: --conky or --plasma');
  process.exit(1);
}

const data = {};

ws.on('error', (e) => {
  if (mode.plasma) {
    plasma.switchToLogMode();
  }
  console.log(`ws error: ${e}`);
});

ws.on('close', (c) => {
  if (mode.plasma) {
    plasma.switchToLogMode();
  }
  console.log(`closed (${c}), reconnecting...`);
});

ws.on('receive', (name, feed) => {
  // group feed to data object
  if (!data[name]) data[name] = {};
  if (feed.price !== undefined) data[name]['price'] = feed.price;
  if (feed.change !== undefined) data[name]['change'] = feed.change;
  if (feed.percent !== undefined) data[name]['percent'] = feed.percent;

  if (mode.conky) {
    const price = `PRICE: ${feed.price}`;
    const change = `${feed.change ? `, CHANGE: ${feed.change}` : ''}`;
    const percent = `${feed.percent ? `, PERCENT: ${feed.percent}%` : ''}`;
    console.log(`${name} -> ${price}${change}${percent}`);
  }

  // feed data object to plasma
  if (mode.plasma) {
    plasma.print(data);
  }

  // feed data object to conky
  if (mode.conky) {
    conky.write(name, data);
  }
});

ws.init(symbols);

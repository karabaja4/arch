const ws = require('./lib/ws');
const plasma = require('./lib/plasma');
const conky = require('./lib/conky');
const symbols = require('./symbols.json').symbols;
const args = require('minimist')(process.argv.slice(2));

const isPlasma = !!args['plasma'];
const isConky = !!args['conky'];

const data = {};

ws.init(symbols, (name, feed) => {

  // group feed to data object
  if (!data[name]) data[name] = {};
  if (feed.price !== undefined) data[name]['price'] = feed.price;
  if (feed.change !== undefined) data[name]['change'] = feed.change;
  if (feed.percent !== undefined) data[name]['percent'] = feed.percent;

  if (isConky) {
    const price = `PRICE: ${feed.price}`;
    const change = `${feed.change ? `, CHANGE: ${feed.change}` : ''}`;
    const percent = `${feed.percent ? `, PERCENT: ${feed.percent}%` : ''}`;
    console.log(`${name} -> ${price}${change}${percent}`);
  }

  // feed data object to plasma
  if (isPlasma) {
    plasma.print(data);
  }

  // feed data object to conky
  if (isConky) {
    conky.write(data);
  }

});


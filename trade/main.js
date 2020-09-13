const store = require('./lib/store').store;
const conky = require('./lib/conky');
const ws = require('./lib/ws');
const plasma = require('./lib/plasma');
const symbols = require('./symbols.json').symbols;
const args = require('minimist')(process.argv.slice(2));

const isPlasma = !!args['plasma'];
const isConky = !!args['conky'];

ws.init(symbols, (name, data) => {

  if (!store[name]) store[name] = {};
  if (data.price !== undefined) store[name]['price'] = data.price;
  if (data.change !== undefined) store[name]['change'] = data.change;
  if (data.percent !== undefined) store[name]['percent'] = data.percent;

  if (isConky) {
    const price = `${name} -> PRICE: ${data.price}`;
    const change = `${data.change ? `, CHANGE: ${data.change}` : ''}`;
    const percent = `${data.percent ? `, PERCENT: ${data.percent}%` : ''}`;
    console.log(`${price}${change}${percent}`);
  }

  if (isPlasma) {
    plasma.print();
  }

});

if (isConky) {
  conky.start();
}

const store = require('./store').store;
const figlet = require('figlet');
const chalk = require('chalk');
const util = require('util');

const symbols = [
  "BITMEX:XBTUSD",
  "TVC:USOIL",
  "TVC:DXY",
  "FOREXCOM:NSXUSD",
  "TVC:SPX",
  "CURRENCYCOM:GOLD",
  "FX:EURUSD",
  "NASDAQ:TSLA"
];

const render = util.promisify(figlet.text);

const print = async () => {
  process.stdout.write('\x1B[2J\x1B[3J\x1B[H\x1Bc');
  const keys = [];
  for(const name in store) {
    if (symbols.includes(name)) {
      keys.push(name);
    }
  }
  keys.sort();
  for(let i = 0; i < keys.length; i++) {
    const key = keys[i];
    const value = store[key];
    const name = `${key.split(':')[1]}:`.padEnd(12);
    const price = `${value.price.toFixed(2)} USD`.padEnd(12);
    const change = `${value.change > 0 ? '+' : ''}${value.change.toFixed(2)} USD`;

    let text = await render(`${name} ${price} | ${change}`, { font: '3x5', width: 1000 });
    text = text.replace(/#/g, '█');
    console.log(chalk[value.change > 0 ? 'green' : 'red'](text));
  }
}


module.exports = {
  print
};
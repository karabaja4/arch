const str = require('./store');
const store = str.store;
const config = str.config;
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
const block = '█';

process.on('exit', () => {
  process.stdout.write('\033[?25h'); // show cursor
});

let lock = false;

const print = async () => {
  if (!lock) {
    lock = true;
    const keys = [];
    for (const name in store) {
      if (symbols.includes(name)) {
        keys.push(name);
      }
    }
    if (keys.length) {
      keys.sort();
      const rows = [];
      rows.push('\n');
      rows.push('\n');
      for (let i = 0; i < keys.length; i++) {
        const key = keys[i];
        const value = store[key];
        const name = `${key.split(':')[1]}:`.padEnd(12);
        const price = `${value.price.toFixed(2)} USD`.padEnd(12);
        const change = `${value.change > 0 ? '+' : ''}${value.change.toFixed(2)} USD`;
        let text = await render(`  ${name} ${price}  |  ${change}  `, { font: '3x5', width: 1000 });
        text = text.replace(/#/g, block);
        // colorize
        const lines = text.split('\n');
        const colors = {
          default: '\033[34m',
          change: value.change > 0 ? '\033[32m' : '\033[31m',
          reset: '\033[0m'
        }
        for (let j = 0; j < lines.length; j++) {
          let line = lines[j];
          if (line.includes(block)) {
            line = `${line.substring(0, 8)}${colors.default}${line.substring(8, line.length)}`;
            line = `${line.substring(0, 129)}${colors.reset}${colors.change}${line.substring(129, line.length)}`;
            line += colors.reset;
          }
          rows.push(line);
        }
      }
      output(rows);
    }
    lock = false;
  }
}

const output = (rows) => {
  if (!config.cleared) {
    process.stdout.write('\033[?25l'); // hide cursor
    console.clear();
    config.cleared = true;
  }
  process.stdout.write('\033[H'); // move to top left
  console.log(rows.join('\n'));
}

module.exports = {
  print
};
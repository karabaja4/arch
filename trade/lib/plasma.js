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

process.on('exit', () => {
  process.stdout.write('\033[?25h'); // show cursor
});

let lock = false;

const print = async () => {
  if (!lock) {
    lock = true;
    const keys = [];
    for(const name in store) {
      if (symbols.includes(name)) {
        keys.push(name);
      }
    }
    keys.sort();
    const rows = [];
    rows.push('\n\n');
    for(let i = 0; i < keys.length; i++) {
      const key = keys[i];
      const value = store[key];
      const name = `${key.split(':')[1]}:`.padEnd(12);
      const price = `${value.price.toFixed(2)} USD`.padEnd(12);
      const change = `${value.change > 0 ? '+' : ''}${value.change.toFixed(2)} USD`;
  
      let text = await render(`  ${name} ${price} | ${change}    `, { font: '3x5', width: 1000 });
      text = text.replace(/#/g, '█');
      const color = value.change > 0 ? 'green' : 'red';
      rows.push(chalk[color](text));
    }
    output(rows);
    lock = false;
  }
}


let cleared = false;

const output = (rows) => {
  if (!cleared) {
    process.stdout.write('\033[?25l'); // hide cursor
    console.clear();
    cleared = true;
  }
  process.stdout.write('\033[H'); // move to top left
  for (let i = 0; i < rows.length; i++) {
    console.log(rows[i]);
  }
}


module.exports = {
  print
};
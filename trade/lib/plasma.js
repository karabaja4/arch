const str = require('./store');
const store = str.store;
const config = str.config;
const figlet = require('figlet');
const util = require('util');

const symbols = [
  "TVC:USOIL",
  "TVC:DXY",
  "FOREXCOM:NSXUSD",
  "TVC:SPX",
  "TVC:GOLD",
  "FX:EURUSD",
  "NASDAQ:TSLA"
];

const escapes = {
  white: '\033[97m',
  green: '\033[32m',
  red: '\033[31m',
  reset: '\033[0m',
  cursor: {
    show: '\033[?25h',
    hide: '\033[?25l',
    moveTopLeft: '\033[H'
  }
};

const render = util.promisify(figlet.text);
const block = '█';

process.on('exit', () => {
  process.stdout.write(escapes.cursor.show); // show cursor
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
        const color = value.change > 0 ? escapes.green : escapes.red;
        for (let j = 0; j < lines.length; j++) {
          let line = lines[j];
          if (line.includes(block)) {
            line = `${line.substring(0, 8)}${escapes.white}${line.substring(8, line.length)}`;
            line = `${line.substring(0, 133)}${escapes.reset}${color}${line.substring(133, line.length)}`;
            line += escapes.reset;
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
    process.stdout.write(escapes.cursor.hide); // hide cursor
    console.clear();
    config.cleared = true;
  }
  process.stdout.write(escapes.cursor.moveTopLeft); // move to top left
  console.log(rows.join('\n'));
}

module.exports = {
  print
};
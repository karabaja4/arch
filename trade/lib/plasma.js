const figlet = require('figlet');
const util = require('util');

const symbols = [
  'FOREXCOM:NSXUSD',
  'TVC:DXY',
  'TVC:USOIL',
  'TVC:SPX',
  'TVC:GOLD',
  'FX:EURUSD',
  'NASDAQ:TSLA',
  'BITMEX:XBTUSD'
];

const escapes = {
  white: '\033[97m',
  gray: '\033[90m',
  green: '\033[92m',
  red: '\033[91m',
  reset: '\033[0m',
  cursor: {
    show: '\033[?25h',
    hide: '\033[?25l',
    moveTopLeft: '\033[H'
  }
};

process.on('SIGINT', () => {
  console.log('exited');
  process.stdout.write(escapes.cursor.show); // show cursor
  process.exit();
});

const render = util.promisify(figlet.text);
const block = '█';

let lock = false;

const insert = (text, ins, index) => {
  return `${text.substring(0, index)}${ins}${text.substring(index, text.length)}`;
};

const print = async (data) => {
  if (!lock) {
    lock = true;
    const keys = [];
    for (let i = 0; i < symbols.length; i++) {
      const symbol = symbols[i];
      if (data[symbol]) {
        keys.push(symbol);
      }
    }
    if (keys.length == symbols.length) { // got all
      const rows = ['\n', '\n'];
      for (let i = 0; i < keys.length; i++) {
        const key = keys[i];
        const value = data[key];
        const name = `${key.split(':')[1]}:`.padEnd(12);
        const price = `${value.price.toFixed(2)} USD`.padEnd(12);
        const change = `${value.change > 0 ? '+' : ''}${value.change.toFixed(2)} USD`;
        let text = await render(`  ${name} ${price}  |  ${change}  `, { font: '3x5', width: 1000 });
        text = text.replace(/#/g, block);
        // colorize
        const lines = text.split('\n');
        const color = value.change >= 0 ? escapes.green : escapes.red;
        for (let j = 0; j < lines.length; j++) {
          let line = lines[j];
          if (line.includes(block)) {
            line = insert(line, `${escapes.white}`, 8);
            line = insert(line, `${escapes.reset}${escapes.gray}`, 122);
            line = insert(line, `${escapes.reset}${color}`, 142);
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

let cleared = false;

const output = (rows) => {
  switchToDrawMode();
  process.stdout.write(escapes.cursor.moveTopLeft); // move to top left
  console.log(rows.join('\n'));
}

const switchToDrawMode = () => {
  if (!cleared) {
    cleared = true;
    process.stdout.write(escapes.cursor.hide);
    console.clear();
  }
}

const switchToLogMode = () => {
  if (cleared) {
    cleared = false;
    process.stdout.write(escapes.cursor.show);
    console.clear();
  }
}

module.exports = {
  print,
  switchToLogMode
};
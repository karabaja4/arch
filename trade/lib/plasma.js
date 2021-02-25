const figlet = require('figlet');
const util = require('util');

const escapes = {
  white: '\033[97m',
  gray: '\033[90m',
  green: '\033[92m',
  red: '\033[91m',
  reset: '\033[0m',
  cursor: {
    show: '\033[?25h',
    hide: '\033[?25l',
    moveTopLeft: '\033[H',
  },
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

const print = async (data, symbols) => {
  if (!lock) {
    lock = true;
    const keys = [];
    for (let i = 0; i < symbols.length; i++) {
      const symbol = symbols[i];
      if (data[symbol]) {
        keys.push(symbol); // counting symbols in data, do not show if not all are there
      }
    }
    if (keys.length == symbols.length) { // got all
      const rows = ['\n', '\n'];
      for (let i = 0; i < keys.length; i++) {
        const key = keys[i];
        const value = data[key];
        const name = `${key.split(':')[1]}:`.padEnd(10);
        const price = `${padFloat(value.price)} USD`.padEnd(12);
        const change = `${value.change > 0 ? '+' : ''}${padFloat(value.change)} USD`;
        let text = await render(`  ${name} ${price}  |  ${change}  `, {font: '3x5', width: 1000});
        text = text.replace(/#/g, block);
        // colorize
        const lines = text.split('\n');
        const color = value.change >= 0 ? escapes.green : escapes.red;
        for (let j = 0; j < lines.length; j++) {
          let line = lines[j];
          if (line.includes(block)) {
            line = insert(line, `${escapes.white}`, 8);
            line = insert(line, `${escapes.reset}${escapes.gray}`, 114);
            line = insert(line, `${escapes.reset}${color}`, 134);
            line = `${line.substring(0, 196).padEnd(196)}${escapes.reset}`;
          } else {
            line = ' '.repeat(200);
          }
          rows.push(line);
        }
      }
      output(rows);
    }
    lock = false;
  }
};

const padFloat = (num) => {
  return num.toLocaleString("en", {
    useGrouping: false,
    minimumFractionDigits: 2,
    maximumFractionDigits: 10
  });
}

let cleared = false;

const output = (rows) => {
  switchToDrawMode();
  process.stdout.write(escapes.cursor.moveTopLeft); // move to top left
  console.log(rows.join('\n'));
};

const switchToDrawMode = () => {
  if (!cleared) {
    cleared = true;
    process.stdout.write(escapes.cursor.hide);
    console.clear();
  }
};

const switchToLogMode = () => {
  if (cleared) {
    cleared = false;
    process.stdout.write(escapes.cursor.show);
    console.clear();
  }
};

module.exports = {
  print,
  switchToLogMode,
};

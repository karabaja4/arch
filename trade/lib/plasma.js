const store = require('./store').store;
const figlet = require('figlet');
const chalk = require('chalk');
const util = require('util');

const render = util.promisify(figlet.text);

const print = async () => {
  console.clear();
  const keys = [];
  for(const name in store) {
    keys.push(name);
  }
  keys.sort();
  for(let i = 0; i < keys.length; i++) {
    const key = keys[i];
    const value = store[key];
    const name = `${key.split(':')[1]}:`.padEnd(12);
    const price = `${value.price.toFixed(2)} USD`.padEnd(12);
    const change = `${value.change > 0 ? '+' : ''}${value.change.toFixed(2)} USD`;

    let text = await render(`${name} ${price} | ${change}`, { font: '3x5' });
    text = text.replace(/#/g, '█');
    console.log(chalk[value.change > 0 ? 'green' : 'red'](text));
  }
}


module.exports = {
  print
};
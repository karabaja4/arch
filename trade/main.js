const ws = require('./lib/ws');
const plasma = require('./lib/plasma');
const symbols = require('./symbols.json').symbols;

const data = {};

ws.on('error', (e) => {
  plasma.switchToLogMode();
  console.log(`ws error: ${e}`);
});

ws.on('close', (c) => {
  plasma.switchToLogMode();
  console.log(`closed (${c}), reconnecting...`);
});

ws.on('receive', (name, feed) => {
  if (!data[name]) data[name] = {};
  if (feed.price !== undefined) data[name]['price'] = feed.price;
  if (feed.change !== undefined) data[name]['change'] = feed.change;
  if (feed.percent !== undefined) data[name]['percent'] = feed.percent;
  plasma.print(data, symbols);
});

const main = async () => {
  console.log('started');
  ws.init(symbols);
};

main();

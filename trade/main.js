const store = require('./lib/store').store;
const conky = require('./lib/conky');
const ws = require('./lib/ws');
const plasma = require('./lib/plasma');
const symbols = require('./symbols.json').symbols;

ws.init(symbols, (name, data) => {

  if (!store[name]) store[name] = {};
  if (data.price !== undefined) store[name]['price'] = data.price;
  if (data.change !== undefined) store[name]['change'] = data.change;
  if (data.percent !== undefined) store[name]['percent'] = data.percent;

  //plasma.print();

});

conky.start();
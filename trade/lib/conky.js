
const fs = require('fs');
const tradeData = '/tmp/trade_data.json';

const getName = () => {
  // const day = (new Date()).getDay();
  // if (day === 6 || day === 0) {
  //   return 'BITMEX:XBTUSD';
  // }
  return 'FX:NGAS';
};

const write = (key, data) => {
  const name = getName();
  if (key !== name) {
    return;
  }
  const values = data[name];
  if (values) {
    const price = data[name]['price'];
    const change = data[name]['change'];
    // const percent = data[name]['percent'];

    const namePrint = name.split(':')[1].replace('USD', '');
    const pricePrint = `${price.toFixed(2)} USD`;
    // const percentPrint = `${percent > 0 ? '+' : ''}${percent.toFixed(2)}%`;
    const changePrint = `${change > 0 ? '+' : ''}${change.toFixed(2)} USD`;

    const result = {
      text: `${namePrint}: ${pricePrint} | ${changePrint}`,
      trend: change > 0
    }

    fs.writeFile(tradeData, JSON.stringify(result), () => {});
  }
};

module.exports = {
  write,
};

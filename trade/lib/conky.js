
const fs = require('fs');

// const name = 'FOREXCOM:NSXUSD';

const trendFile = '/tmp/asset_trend';
const valueFile = '/tmp/asset_value';

const green = '#69F0AE';
const red = '#FF6E40';
const gray = '#757575';

const getName = () => {
  // const day = (new Date()).getDay();
  // if (day === 6 || day === 0) {
  //   return 'BITMEX:XBTUSD';
  // }
  // return 'FOREXCOM:NSXUSD';
  return 'BITMEX:XBTUSD';
};

const init = async () => {
  await fs.promises.writeFile(trendFile, gray);
  await fs.promises.writeFile(valueFile, 'TRD: not connected');
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

    fs.writeFile(trendFile, `${change >= 0 ? green : red}`, () => {});
    fs.writeFile(valueFile, `${namePrint}: ${pricePrint} | ${changePrint}`, () => {});
  }
};

module.exports = {
  init,
  write,
};


const fs = require('fs');
const store = require('./store').store;

const name = 'FOREXCOM:NSXUSD';
const trendFile = '/tmp/asset_trend';
const valueFile = '/tmp/asset_value';
const green = '#69F0AE';
const red = '#FF6E40';

const start = () => {

  setInterval(async () => {
    try {
      const values = store[name];
      if (values) {
        const price = store[name]['price'];
        const change = store[name]['change'];
        //const percent = store[name]['percent'];

        const namePrint = name.split(':')[1].replace('USD', '');
        const pricePrint = `${price.toFixed(2)} USD`;
        //const percentPrint = `${percent > 0 ? '+' : ''}${percent.toFixed(2)}%`;
        const changePrint = `${change > 0 ? '+' : ''}${change.toFixed(2)} USD`;

        await fs.promises.writeFile(trendFile, `${change > 0 ? green : red}`);
        await fs.promises.writeFile(valueFile, `${namePrint}: ${pricePrint} | ${changePrint}`);
      }
    } catch (e) {
      console.log(`conky error: ${e}`);
    }
  }, 1000);

}

module.exports = {
  start
};
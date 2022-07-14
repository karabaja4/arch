const fs = require('fs');
const timers = require('timers/promises');

const colors = [
  "#ff0000",
  "#00ff00",
  "#0000ff",
  "#ffff00",
  "#ff00ff",
  "#00ff00",
  "#00ffff",
  "#0000ff"
]

const interval = 1000;
let idx = 0;

const main = async () => {
  while (true) {
    const date = new Date();
    const h = date.getHours();
    const m = date.getMinutes().toString().padStart(2, '0');
    const s = date.getSeconds().toString().padStart(2, '0');
    const result = {
      text: `${h}:${m}:${s}`,
      color: colors[idx++ % colors.length],
      size: 200,
      interval: interval,
      digital: true
    };
    await fs.promises.writeFile('/home/igor/_static/ad307b2c60c32dc4.json', JSON.stringify(result));
    await timers.setTimeout(interval);
  }
}

main();
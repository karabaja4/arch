const fs = require('fs');
const timers = require('timers/promises');

const colors = [
  "#0000ff",
  "#00ff00",
  "#00ffff",
  "#ff0000",
  "#ff00ff",
  "#ffff00",
  "#ffffff"
]

const interval = 1000;
let idx = 0;

const localDate = () => {
  return new Date().toLocaleString('en-US', { timeZone: 'Europe/Zagreb' });
}

const main = async () => {
  while (true) {
    const date = new Date(localDate());
    const h = date.getHours();
    const m = date.getMinutes().toString().padStart(2, '0');
    const sec = date.getSeconds();
    let word = null;
    let s = null;
    if (sec === 30) word = "Have";
    else if (sec === 31) word = "a";
    else if (sec === 32) word = "nice";
    else if (sec === 33) word = "day";
    else if (sec === 34) word = ":)"
    else s = sec.toString().padStart(2, '0');
    const result = {
      text: word || `${h}:${m}:${s}`,
      color: colors[idx++ % colors.length],
      size: 200,
      interval: interval,
      digital: !word
    };
    await fs.promises.writeFile('/home/igor/_static/ad307b2c60c32dc4.json', JSON.stringify(result));
    await timers.setTimeout(interval);
  }
}

main();
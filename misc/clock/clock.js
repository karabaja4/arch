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
];

const morning = "Dobro jutro :)";
const day =     "Želim ti dobar dan :)";
const evening = "Želim ti ugodnu večer :)";
const night =   "Želim ti laku noć :)";

const greetings = (hour) => {
  if (hour == 23 || (hour >= 0 && hour <= 3)) {
    return night;
  }
  if (hour >= 4 && hour <= 11) {
    return morning;
  }
  if (hour >= 12 && hour <= 17) {
    return day;
  }
  if (hour >= 18 && hour <= 22) {
    return evening;
  }
  return [];
};

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

    const words = greetings(h).split(' ');
    const word = words[sec - 30];

    const result = {
      text: word || `${h}:${m}:${sec.toString().padStart(2, '0')}`,
      color: colors[idx++ % colors.length],
      size: word ? 180 : 200,
      interval: interval,
      digital: !word
    };
    await fs.promises.writeFile('/home/igor/_static/ad307b2c60c32dc4.json', JSON.stringify(result));
    await timers.setTimeout(interval);
  }
}

main();
const express = require('express');
const app = express();

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

const localDate = () => {
  return new Date().toLocaleString('en-US', { timeZone: 'Europe/Zagreb' });
};

const port = 42811;

app.get('/', async (req, res) => {

  const date = new Date(localDate());
  const h = date.getHours();
  const m = date.getMinutes().toString().padStart(2, '0');
  const sec = date.getSeconds();
  const ts = Math.trunc(date.getTime() / 1000);

  const words = greetings(h).split(' ');
  const word = words[sec - 30];

  const result = {
    text: word || `${h}:${m}:${sec.toString().padStart(2, '0')}`,
    color: colors[ts % colors.length],
    size: word ? 180 : 200,
    interval: interval,
    digital: !word
  };

  res.send(result);
});

app.listen(port, () => {
  console.log(`listening on port ${port}`)
});
const express = require('express');
const app = express();
const axios = require('axios');
const timers = require('timers/promises');

app.get('/tick/:id', (req, res) => {

  console.log(`tick @ ${req.params.id}`);

  // GT-I9300
  if (req.params.id === 'ad307b2c60c32dc4') {
    res.send(getClock(200));
    return;
  }

  // tv box
  else if (req.params.id === 'e24058c14eb304fc') {
    res.send(getClock(300));
    return;
  }

  // android studio emulator
  else if (req.params.id === 'b4041919f2a050e7') {
    res.send(getHello());
    return;
  }

  // btc
  else {
    res.send(getPrice());
    return;
  }
  
});

const getHello = () => {
  const result = {
    text: "Hello :)",
    color: colors[4],
    size: 150,
    interval: 1000,
    digital: false
  };
  return result;
}

const colors = [
  "#0000ff", // blue
  "#00ff00", // green
  "#00ffff", // cyan
  "#ff0000", // red
  "#ff00ff", // pink
  "#ffff00", // yellow
  "#ffffff"  // white
];

// clock
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

const localDate = () => {
  return new Date().toLocaleString('en-US', { timeZone: 'Europe/Zagreb' });
};

const getClock = (size) => {
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
    size: word ? (size - 20) : size,
    interval: 1000,
    digital: !word
  };
  return result;
}

// price
let price = '---';
const loop = async () => {
  const url = 'https://www.bitmex.com/api/v1/trade?symbol=XBT&count=1&reverse=true';
  while (true) {
    try {
      const result = await axios.get(url);
      price = Math.trunc(result.data[0].price).toString();
      console.log(`GET ${url} => ${result.status} ${result.statusText}`);
    } catch (e) {
      price = '---';
      console.log(e.message);
    }
    await timers.setTimeout(10000);
  }
}
loop();
const getPrice = () => {
  const result = {
    text: price,
    color: colors[1],
    size: 200,
    interval: 5000,
    digital: true
  };
  return result;
}

// listen
const port = 42822;
app.listen(port, () => {
  console.log(`Listening on port ${port}.`);
});
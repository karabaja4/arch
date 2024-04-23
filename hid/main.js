const fs = require('fs');
const timers = require('node:timers/promises');
const { mapArray, mapObject } = require('./keys');

const text = [ "h", "e", "l", "l", "o", "SPACE", "w", "o", "r", "l", "d", "ENTER" ];

const send = async (data) => {
  await fs.promises.writeFile('/dev/hidg0', data);
};

const write = async (key) => {
  const buttons = mapObject[key];
  const release = mapObject['RELEASE'];
  if (buttons && release) {
    await send(buttons);
    await send(release);
  }
};

const main = async () => {
  for (let i = 0; i < text.length; i++) {
    const item = text[i];
    console.log(item);
    write(item);
    await timers.setTimeout(200);
  }
};

main();
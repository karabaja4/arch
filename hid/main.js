const fs = require('fs');
const timers = require('node:timers/promises');
const { mapArray, mapObject } = require('./keys');

const text1 = [ "" ];
const text2 = [ "" ];

const send = async (data) => {
  await fs.promises.writeFile('/dev/hidg0', data);
};

const write = async (key) => {
  console.log(key);
  const buttons = mapObject[key];
  const release = mapObject['RELEASE'];
  if (buttons && release) {
    await send(buttons);
    await send(release);
  }
};

const main = async () => {
  
  write("ESCAPE");
  await timers.setTimeout(5000);
  
  for (let i = 0; i < text1.length; i++) {
    write(text1[i]);
    await timers.setTimeout(300);
  }
  
  await timers.setTimeout(2000);
  write("TAB");
  await timers.setTimeout(2000);
  
  for (let i = 0; i < text2.length; i++) {
    write(text2[i]);
    await timers.setTimeout(300);
  }
  
  await timers.setTimeout(2000);
  write("ENTER");
  
};

main();
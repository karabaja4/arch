const fs = require('node:fs');
const EventEmitter = require('node:events');
const bus = new EventEmitter();

const logpath = '/tmp/cron.log';

const queue = [];
let processing = false;

const unpack = (err) => {
  return (err.stack || err.message || err)?.trim();
};

const process = async () => {
  if (processing) return;
  processing = true;
  try {
    while (queue.length > 0) {
      const item = queue.shift();
      await fs.promises.appendFile(logpath, item);
    };
  } catch (err) {
    console.log(`Error writing to log: ${unpack(err)}`);
  } finally {
    processing = false;
    if (queue.length > 0) process();
  }
};
bus.on('log-added', process);

const push = (type, message) => {
  const utc = (new Date()).toISOString();
  const formatted = `[${utc}][${type}] ${unpack(message)}`;
  console.log(formatted);
  queue.push(`${formatted}\n`);
  bus.emit('log-added');
};

module.exports = {
  push
};

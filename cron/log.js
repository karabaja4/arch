const fs = require('node:fs');
const logpath = '/tmp/cron.log';

const queue = [];
let processing = false;

const unpack = (err) => {
  try {
    if (!err) return '';
    return (err.stack || err.message || String(err)).toString().trim();
  } catch {
    return '(unpack error)';
  }
};

const processQueue = async () => {
  if (processing) return;
  processing = true;
  try {
    while (queue.length > 0) {
      const item = queue.shift();
      try {
        await fs.promises.appendFile(logpath, item);
      } catch (err) {
        console.log(`Error writing to log: ${unpack(err)}`);
      }
    }
  } finally {
    processing = false;
    // catch any logs added during finishing before processing was set to false
    if (queue.length > 0) setImmediate(processQueue);
  }
};

const push = (type, message) => {
  const utc = (new Date()).toISOString();
  const formatted = `[${utc}][${type}] ${unpack(message)}`;
  console.log(formatted);
  queue.push(`${formatted}\n`);
  processQueue();
};

module.exports = {
  push
};

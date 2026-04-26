const fs = require('node:fs');
const logpath = '/var/log/cron.log';

const stream = fs.createWriteStream(logpath, { flags: 'a' });

const unpack = (err) => {
  try {
    if (!err) return '';
    return (err.stack || err.message || String(err)).toString().trim();
  } catch {
    return '(unpack error)';
  }
};

let canWrite = true;

const push = (source, type, message) => {
  const utc = (new Date()).toISOString();
  const formatted = `[${utc}][${source}][${type}] ${unpack(message)}`;
  console.log(formatted);

  if (!canWrite) return;
  
  canWrite = stream.write(`${formatted}\n`);
  if (!canWrite) {
    stream.once('drain', () => {
      canWrite = true;
    });
  }
};

const close = () => new Promise((resolve) => stream.end(resolve));

module.exports = {
  push,
  close
};

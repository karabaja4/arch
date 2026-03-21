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

const push = (source, type, message) => {
  return new Promise((resolve, reject) => {
    const utc = (new Date()).toISOString();
    const formatted = `[${utc}][${source}][${type}] ${unpack(message)}`;
    console.log(formatted);
    stream.write(`${formatted}\n`, (err) => {
      if (err) {
        reject(err);
      } else {
        resolve();
      }
    });
  });
};

const close = () => new Promise((resolve) => stream.end(resolve));

module.exports = {
  push,
  close
};

const fs = require('node:fs');
const logpath = '/tmp/cron.log';

const stream = fs.createWriteStream(logpath, { flags: 'a' });

const unpack = (err) => {
  try {
    if (!err) return '';
    return (err.stack || err.message || String(err)).toString().trim();
  } catch {
    return '(unpack error)';
  }
};

const format = (source, type, message) => {
  const utc = (new Date()).toISOString();
  return `[${utc}][${source}][${type}] ${unpack(message)}`;
};

const push = (source, type, message) => {
  return new Promise((resolve, reject) => {
    const formatted = format(source, type, message);
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

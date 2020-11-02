const os = require('os');
const fs = require('fs');
const path = require('path');

const logdir = path.join(os.homedir(), '.local/share/mimejs');
const logfile = path.join(logdir, 'mimejs.log');

const write = async (tag, msg) => {
  await fs.promises.mkdir(logdir, { recursive: true });
  await fs.promises.appendFile(logfile, `[${(new Date()).toISOString()}][${tag}]: ${msg}\n`);
};

module.exports = {
  write
};

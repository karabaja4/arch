const os = require('os');
const fs = require('fs');
const path = require('path');

const cfgfile = 'mime.json';

const readfile = async (p) => {
  return await fs.promises.readFile(p, 'utf-8').catch(e => null);
};

const readcfg = async () => {
  const usr = path.join(os.homedir(), `.${cfgfile}`);
  const sys = path.join('/etc', cfgfile);
  return await readfile(usr) || await readfile(sys);
};

const read = async () => {
  return JSON.parse(await readcfg());
};

module.exports = {
  read
};

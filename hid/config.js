const config = require('./config.json');
const log = require('./log');

const isValid = () => {
  return config.username && config.password;
}

const get = () => {
  if (!isValid()) {
    log.fatal('Invalid config.json');
  }
  return config;
}

module.exports = {
  get
};

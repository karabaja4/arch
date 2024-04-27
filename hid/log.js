const info = (text) => {
  if (text) {
    console.log('\x1b[94m%s\x1b[0m', text);
  }
};

const success = (text) => {
  if (text) {
    console.log('\x1b[92m%s\x1b[0m', text);
  }
};

const error = (text) => {
  if (text) {
    console.log('\x1b[91m%s\x1b[0m', text);
  }
};

const fatal = (text) => {
  error(text);
  process.exit(1);
};

module.exports = {
  info,
  success,
  error,
  fatal
};
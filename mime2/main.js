const args = require('minimist')(process.argv.slice(2));
const path = require('path');
const util = require('util');
const nm = require('nanomatch');
const exec = util.promisify(require('child_process').exec);
const cfg = require('./config.json');
const arg = args._[0];

if (!arg) {
  console.log('invalid arguments');
  process.exit(1);
}

const vars = {
  '$pwd': process.cwd(),
  '$arg': `'${arg}'`
};

const replace = (cmd) => {
  for (const [ name, value ] of Object.entries(vars)) {
    cmd = cmd.replace(name, value);
  }
  return cmd;
}

const exit = (cmd) => {
  console.log(replace(cmd));
  return process.exit(0);
}

const main = async () => {

  // extensions
  const extension = path.extname(arg).replace('.', '');
  if (extension) {
    const extensions = cfg['extensions'] || {};
    for (const [ ext, cmd ] of Object.entries(extensions)) {
      if (nm.isMatch(extension, ext)) {
        return exit(cmd);
      }
    }
  }

  // mimetypes
  try {
    const mimetypes = cfg['mimetypes'] || {};
    const { stdout } = await exec(`file -E --brief --mime-type '${arg}'`);
    for (const [ mime, cmd ] of Object.entries(mimetypes)) {
      if (nm.isMatch(stdout.trim(), mime)) {
        return exit(cmd);
      }
    }
  } catch (e) {}

  // protocols
  if (nm.isMatch(arg, '*://**')) {
    const protocols = cfg['protocols'] || {};
    for (const [ prot, cmd ] of Object.entries(protocols)) {
      if (nm.isMatch(arg, prot)) {
        return exit(cmd);
      }
    }
  }

}

main();
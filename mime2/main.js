const args = require('minimist')(process.argv.slice(2));
const path = require('path');
const util = require('util');
const mm = require('micromatch');
const exec = util.promisify(require('child_process').exec);
const cfg = require('./config.json');
const arg = args._[0];

const main = async () => {

  if (!arg) {
    console.log('invalid arguments');
    process.exit(1);
  }

  const vars = {
    '$pwd': process.cwd(),
    '$arg': arg
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
  
  // extensions
  const extension = path.extname(arg).replace('.', '');
  if (extension) {
    const extensions = cfg['extensions'] || {};
    for (const [ ext, cmd ] of Object.entries(extensions)) {
      if (mm.isMatch(extension, ext)) {
        return exit(cmd);
      }
    }
  }

  // mimetypes
  try {
    const mimetypes = cfg['mimetypes'] || {};
    const { stdout } = await exec(`file -E --brief --mime-type ${arg}`);
    for (const [ mime, cmd ] of Object.entries(mimetypes)) {
      if (mm.isMatch(stdout.trim(), mime)) {
        return exit(cmd);
      }
    }
  } catch (e) {}

  // protocols
  if (arg.match(/^[a-z]+:\/\/.+$/gi)) {
    const protocols = cfg['protocols'] || {};
    for (const [ ptc, cmd ] of Object.entries(protocols)) {
      if (mm.isMatch(arg, ptc)) {
        return exit(cmd);
      }
    }
  }

}

main();
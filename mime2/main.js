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
  '$pwd': `'${process.cwd()}'`,
  '$arg': `'${arg}'`
};

const sub = (cmd) => {
  // stupid fix for qtfm
  if (cmd.startsWith('qtfm') && arg === '.') {
    cmd = cmd.replace('$arg', '$pwd');
  }
  for (const key in vars) {
    cmd = cmd.replace(key, vars[key]);
  }
  return cmd;
}

const exit = async (cmd) => {
  const command = sub(cmd);
  await exec(command);
  return 0;
}

const match = (value, glob) => {
  return nm.isMatch(value, glob.replace(/\*+/gi, '**'), { nonegate: true });
}

const main = async () => {

  // extensions
  const ext = path.extname(arg).replace('.', '');
  if (ext) {
    const extensions = cfg['extensions'] || {};
    for (const key in extensions) {
      const splits = key.split('|');
      for (let i = 0; i < splits.length; i++) {
        if (match(ext, splits[i])) {
          return await exit(extensions[key]);
        }
      }
    }
  }

  // mimetypes
  try {
    const mimetypes = cfg['mimetypes'] || {};
    const { stdout } = await exec(`file -E --brief --mime-type '${arg}'`);
    for (const key in mimetypes) {
      if (match(stdout.trim(), key)) {
        return await exit(mimetypes[key]);
      }
    }
  } catch (e) {}

  // protocols
  if (arg.match(/^[a-z]+:\/\/.+$/gi)) {
    const protocols = cfg['protocols'] || {};
    for (const key in protocols) {
      if (match(arg, key)) {
        return await exit(protocols[key]);
      }
    }
  }

}

main();
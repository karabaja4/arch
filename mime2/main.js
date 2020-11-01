// pkg --targets linux main.js

const args = require('minimist')(process.argv.slice(2));
const path = require('path');
const util = require('util');
const fs = require('fs');
const os = require('os');
const nm = require('nanomatch');
const exec = util.promisify(require('child_process').exec);
const cfgfile = 'mime.json';
const rarg = args._[0];

const error = (msg) => {
  console.error(msg);
  process.exit(1);
}

if (!rarg) {
  error('Invalid arguments');
}

const escape = (value) => {
  return value.replace(/'/g, "'\\''");
}

const arg = escape(rarg);
const cwd = escape(process.cwd());

const vars = {
  '$pwd': `'${cwd}'`,
  '$arg': `'${arg}'`
};

const sub = (cmd) => {
  // stupid fix for qtfm
  if (cmd.startsWith('qtfm') && arg === '.') {
    cmd = cmd.replace('$arg', '$pwd');
  }
  for (const key in vars) {
    cmd = cmd.replace(key, () => vars[key]);
  }
  return cmd;
}

const exit = async (cmd) => {
  const command = sub(cmd);
  return await exec(`( ${command} & ) &> /dev/null &`);
}

const match = (value, glob) => {
  return nm.isMatch(value, glob.replace(/\*+/gi, '**'), { nonegate: true });
}

const main = async () => {

  const home = await fs.promises.readFile(path.join(os.homedir(), `.${cfgfile}`)).catch(e => null);
  const root = await fs.promises.readFile(path.join('/etc', cfgfile)).catch(e => null);

  if (!home && !root) {
    return error('Config file not found or not readable');
  }

  const cfg = JSON.parse((home || root).toString());

  // extensions
  const ext = path.extname(arg).replace('.', '');
  if (ext) {
    const extensions = cfg['extensions'] || {};
    for (const key in extensions) {
      const splits = key.split(',');
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

  return error(`Unable to match suitable application for ${arg}`);
}

main();
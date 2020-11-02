// pkg --targets linux main.js
// sudo ln -sf /home/igor/arch/mime2/main /usr/bin/xdg-open

const args = require('minimist')(process.argv.slice(2));
const path = require('path');
const util = require('util');
const nm = require('nanomatch');
const exec = util.promisify(require('child_process').exec);
const log = require('./lib/log');
const cfg = require('./lib/config');

if (args.help || args._.length !== 1) {
  console.log('mimejs 0.1\n\nusage: xdg-open { file | URL }');
  process.exit(1);
}

const main = async () => {

  const fatal = async (msg) => {
    await log.write('error', msg);
    console.error(msg);
    return process.exit(1);
  };
  
  const esc = (value) => {
    return value.replace(/'/g, "'\\''");
  };
  
  const arg = esc(args._[0]);
  const cwd = esc(process.cwd());
  
  const vars = {
    '$arg': `'${arg}'`,
    '$pwd': `'${cwd}'`
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
  };
  
  const execute = async (cmd) => {
    const command = sub(cmd);
    await log.write('info', `Executing: ${command}`);
    return await exec(`( ${command} & ) &> /dev/null &`);
  };
  
  const match = (value, glob) => {
    return nm.isMatch(value, glob.replace(/\*+/gi, '**'), { nonegate: true });
  };

  const config = await cfg.get();
  if (!config) {
    return await fatal('Config file not found or not readable');
  }

  // extensions
  const ext = path.extname(arg).replace('.', '');
  if (ext) {
    const extensions = config['extensions'] || {};
    for (const key in extensions) {
      const splits = key.split(',');
      for (let i = 0; i < splits.length; i++) {
        if (match(ext, splits[i])) {
          return await execute(extensions[key]);
        }
      }
    }
  }

  // mimetypes
  try {
    const mimetypes = config['mimetypes'] || {};
    const { stdout } = await exec(`file -E --brief --mime-type '${arg}'`);
    for (const key in mimetypes) {
      if (match(stdout.trim(), key)) {
        return await execute(mimetypes[key]);
      }
    }
  } catch (e) {}

  // protocols
  if (arg.match(/^[a-z]+:\/\/.+$/gi)) {
    const protocols = config['protocols'] || {};
    for (const key in protocols) {
      if (match(arg, key)) {
        return await execute(protocols[key]);
      }
    }
  }

  return await fatal(`No suitable command: ${arg}`);
}

main();
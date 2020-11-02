// pkg --targets linux main.js
// sudo ln -sf /home/igor/arch/mime2/main /usr/bin/xdg-open

const args = require('minimist')(process.argv.slice(2));
const path = require('path');
const util = require('util');
const fs = require('fs');
const os = require('os');
const nm = require('nanomatch');
const exec = util.promisify(require('child_process').exec);
const cfgfile = 'mime.json';
const logfile = 'mimejs.log';

if (args.help || args._.length !== 1) {
  console.log('mimejs 0.1\n\nusage: xdg-open { file | URL }');
  process.exit(1);
}

const main = async () => {

  const logdir = path.join(os.homedir(), '.local/share/mimejs');
  await fs.promises.mkdir(logdir, { recursive: true });

  const log = async (tag, msg) => {
    await fs.promises.appendFile(path.join(logdir, logfile), `[${(new Date()).toISOString()}][${tag}]: ${msg}\n`);
  }

  const fatal = async (msg) => {
    await log('error', msg);
    console.error(msg);
    return process.exit(1);
  }
  
  const esc = (value) => {
    return value.replace(/'/g, "'\\''");
  }
  
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
  }
  
  const execute = async (cmd) => {
    const command = sub(cmd);
    await log('info', `Executing: ${command}`);
    return await exec(`( ${command} & ) &> /dev/null &`);
  }
  
  const match = (value, glob) => {
    return nm.isMatch(value, glob.replace(/\*+/gi, '**'), { nonegate: true });
  }

  const saferf = async (p) => {
    return await fs.promises.readFile(p, 'utf-8').catch(e => null);
  }

  const readcfg = async () => {
    const cfgusr = path.join(os.homedir(), `.${cfgfile}`);
    const cfgsys = path.join('/etc', cfgfile);
    return await saferf(cfgusr) || await saferf(cfgsys);
  }

  const json = await readcfg();

  if (!json) {
    return await fatal('Config file not found or not readable');
  }

  const cfg = JSON.parse(json);

  // extensions
  const ext = path.extname(arg).replace('.', '');
  if (ext) {
    const extensions = cfg['extensions'] || {};
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
    const mimetypes = cfg['mimetypes'] || {};
    const { stdout } = await exec(`file -E --brief --mime-type '${arg}'`);
    for (const key in mimetypes) {
      if (match(stdout.trim(), key)) {
        return await execute(mimetypes[key]);
      }
    }
  } catch (e) {}

  // protocols
  if (arg.match(/^[a-z]+:\/\/.+$/gi)) {
    const protocols = cfg['protocols'] || {};
    for (const key in protocols) {
      if (match(arg, key)) {
        return await execute(protocols[key]);
      }
    }
  }

  return await fatal(`No suitable command: ${arg}`);
}

main();
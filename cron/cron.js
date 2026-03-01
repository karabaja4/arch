const util = require('node:util');
const os = require('node:os');
const fs = require('node:fs');
const path = require('node:path');
const exec = util.promisify(require('node:child_process').exec);
const timers = require('node:timers/promises');
const log = require('./log');

const every = {
  seconds: (n) => (n * 1000),
  minutes: (n) => (n * 60 * 1000),
  hours:   (n) => (n * 60 * 60 * 1000),
  days:    (n) => (n * 24 * 60 * 60 * 1000)
};

const users = {
  igor: { name: 'igor', uid: 1000, home: '/home/igor' },
  root: { name: 'root', uid: 0,    home: '/root'      }
};

const definitions = [
  {
    id: 'fstrim',
    path: '/home/igor/arch/scripts/fstrim.sh',
    interval: every.days(7),
    user: users.root
  },
  {
    id: 'dpms',
    path: '/home/igor/arch/scripts/dpms.sh',
    interval: every.minutes(5),
    user: users.igor
  },
  {
    id: 'updates',
    path: '/home/igor/arch/scripts/updates.sh',
    interval: every.minutes(5),
    user: users.igor
  }
];

const run = async (id, command, interval, user, wait) => {
  if (wait > 0) {
    log.push('INFO', `${id} waiting for ${wait}ms`);
    await timers.setTimeout(wait);
  } else {
    log.push('INFO', `${id} is overdue or has never run, starting immediately.`);
  }
  try {
    const line = `(UID: ${user.uid}) ${command}`;
    log.push('START', line);
    const content = await exec(command, {
      uid: user.uid,
      gid: user.uid,
      env: { 
        USER: user.name,
        HOME: user.home,
        SHELL: '/bin/sh',
        PATH: process.env['PATH']
      },
      maxBuffer: 1024 * 1024 * 5
    });
    if (content.stdout) {
      log.push('STDOUT', content.stdout);
    }
    if (content.stderr) {
      log.push('STDERR', content.stderr);
    }
    log.push('END', line);
  } catch (err) {
    log.push('ERROR', err);
  }
  await setLastRunTime(id, Date.now());
  setImmediate(() => run(id, command, interval, user, interval));
};

const crondir = path.join(os.homedir(), '.local/share/cron');

const getLastRunTime = async (id) => {
  try {
    const filepath = path.join(crondir, `${id}.lrt`);
    const content = await fs.promises.readFile(filepath, 'utf8');
    const result = parseInt(content.trim());
    if (Number.isInteger(result)) {
      return result;
    }
    log.push('INFO', `Last run time for ${id} is invalid.`);
  } catch (err) {
    if (err.code === 'ENOENT') {
      log.push('INFO', `Last run time for ${id} not found.`);
    } else {
      throw err;
    }
  }
  return 0;
};

const setLastRunTime = async (id, ts) => {
  const filepath = path.join(crondir, `${id}.lrt`);
  await fs.promises.writeFile(filepath, ts.toString());
};

const main = async () => {
  await fs.promises.mkdir(crondir, { recursive: true });
  for (let i = 0; i < definitions.length; i++) {
    const def = definitions[i];
    const lastRunTime = await getLastRunTime(def.id);
    const elapsed = (lastRunTime === 0) ? Infinity : (Date.now() - lastRunTime);
    const wait = (elapsed >= def.interval) ? 0 : (def.interval - elapsed);
    run(def.id, def.path, def.interval, def.user, wait);
  }
};

main();

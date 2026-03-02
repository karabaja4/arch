const util = require('node:util');
const os = require('node:os');
const fs = require('node:fs');
const path = require('node:path');
const timers = require('node:timers/promises');
const exec = util.promisify(require('node:child_process').exec);
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

const crondir = path.join(os.homedir(), '.local/share/cron');
const getLastRunTimePath = (id) => path.join(crondir, `${id}.lrt`);

const getLastRunTime = async (id) => {
  try {
    const filepath = getLastRunTimePath(id);
    const content = await fs.promises.readFile(filepath, 'utf8');
    const result = parseInt(content.trim());
    if (Number.isInteger(result)) {
      return result;
    }
    log.push(id, 'LRT', `Last run time for ${id} is invalid.`);
  } catch (err) {
    if (err.code === 'ENOENT') {
      log.push(id, 'LRT', `Last run time for ${id} was not found.`);
    } else {
      throw err;
    }
  }
  return 0;
};

const setLastRunTime = async (id, ts) => {
  const filepath = getLastRunTimePath(id);
  await fs.promises.writeFile(filepath, ts.toString());
};

const run = async (id, command, interval, user, wait) => {
  if (wait > 0) {
    log.push(id, 'RUN', `Job waiting for ${wait}ms`);
    await timers.setTimeout(wait);
  } else {
    log.push(id, 'RUN', 'Job is overdue or has never run, starting immediately.');
  }
  try {
    log.push(id, 'START', `(UID: ${user.uid}) ${command}`);
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
      log.push(id, 'STDOUT', content.stdout);
    }
    if (content.stderr) {
      log.push(id, 'STDERR', content.stderr);
    }
    log.push(id, 'END', 'Job ended.');
  } catch (err) {
    log.push(id, 'ERROR', err);
  }
  await setLastRunTime(id, Date.now());
  setImmediate(() => run(id, command, interval, user, interval));
};

const main = async () => {
  try {
    await fs.promises.mkdir(crondir, { recursive: true });
    for (let i = 0; i < definitions.length; i++) {
      const def = definitions[i];
      const lastRunTime = await getLastRunTime(def.id);
      const elapsed = (lastRunTime === 0) ? Infinity : (Date.now() - lastRunTime);
      const wait = (elapsed >= def.interval) ? 0 : (def.interval - elapsed);
      run(def.id, def.path, def.interval, def.user, wait);
    }
  } catch (err) {
    await log.push('main', 'ERROR', err);
    await log.close();
    process.exit(1);
  }
};

main();

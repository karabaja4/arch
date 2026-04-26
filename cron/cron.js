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

const jobs = [
  {
    id: 'fstrim',
    command: '/home/igor/arch/scripts/fstrim.sh',
    interval: every.days(7),
    user: users.root,
    online: false
  },
  {
    id: 'dpms',
    command: '/home/igor/arch/scripts/dpms.sh',
    interval: every.minutes(5),
    user: users.igor,
    online: false
  },
  {
    id: 'updates',
    command: '/home/igor/arch/scripts/updates.sh',
    interval: every.minutes(5),
    user: users.igor,
    online: true
  }
];

const isOnline = async () => {
  try {
    const res = await fetch('https://avacyn.radiance.hr/ip', {
      method: 'HEAD',
      signal: AbortSignal.timeout(2000),
    });
    return res.status === 200;
  } catch {
    return false;
  }
};

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

const run = async (job, wait) => {
  if (wait > 0) {
    log.push(job.id, 'RUN', `Job waiting for ${wait}ms`);
    await timers.setTimeout(wait);
  } else {
    log.push(job.id, 'RUN', 'Job is overdue or has never run, starting immediately.');
  }
  try {
    log.push(job.id, 'START', `(UID: ${job.user.uid}) ${job.command}`);
    const shouldRun = !job.online || await isOnline();
    if (!shouldRun) {
      log.push(job.id, 'ERROR', 'The job requires an internet connection, but none was available.');
    }
    if (shouldRun) {
      const content = await exec(job.command, {
        uid: job.user.uid,
        gid: job.user.uid,
        env: { 
          USER: job.user.name,
          HOME: job.user.home,
          SHELL: '/bin/sh',
          PATH: process.env['PATH']
        },
        maxBuffer: 1024 * 1024 * 5
      });
      if (content.stdout) {
        log.push(job.id, 'STDOUT', content.stdout);
      }
      if (content.stderr) {
        log.push(job.id, 'STDERR', content.stderr);
      }
    }
    log.push(job.id, 'END', 'Job ended.');
  } catch (err) {
    log.push(job.id, 'ERROR', err);
  }
  await setLastRunTime(job.id, Date.now());
  setImmediate(() => run(job, job.interval));
};

const main = async () => {
  try {
    await fs.promises.mkdir(crondir, { recursive: true });
    for (let i = 0; i < jobs.length; i++) {
      const job = jobs[i];
      const lastRunTime = await getLastRunTime(job.id);
      const elapsed = (lastRunTime === 0) ? Infinity : (Date.now() - lastRunTime);
      const wait = (elapsed >= job.interval) ? 0 : (job.interval - elapsed);
      run(job, wait);
    }
  } catch (err) {
    await log.push('main', 'ERROR', err);
    await log.close();
    process.exit(1);
  }
};

const shutdown = async () => {
  try {
    await log.push('main', 'SHUTDOWN', 'Shutting down, goodbye.');
    await log.close();
    console.log('Exiting.');
  } finally {
    process.exit(0);
  }
};

process.on('SIGHUP', shutdown);
process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);

main();

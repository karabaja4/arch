const util = require('node:util');
const exec = util.promisify(require('node:child_process').exec);
const timers = require('node:timers/promises');
const log = require('./log');

const run = async (command, interval, user) => {
  while (true) {
    try {
      const infoline = `(UID: ${user.uid}) ${command}`;
      log.push('START', infoline);
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
      log.push('END', infoline);
    } catch (err) {
      log.push('ERROR', err.stack || err.message || err);
    }
    await timers.setTimeout(interval);
  }
};

const every = {
  seconds: (n) => (n * 1000),
  minutes: (n) => (n * 60 * 1000),
  hours:   (n) => (n * 60 * 60 * 1000)
};

const users = {
  igor: { name: 'igor', uid: 1000, home: '/home/igor' },
  root: { name: 'root', uid: 0,    home: '/root'      }
};

// root
run('/home/igor/arch/scripts/fstrim.sh', every.hours(6), users.root);

// igor
run('/home/igor/arch/scripts/dpms.sh', every.minutes(5), users.igor);
run('/home/igor/arch/scripts/updates.sh', every.minutes(5), users.igor);

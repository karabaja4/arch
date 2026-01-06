const util = require('node:util');
const exec = util.promisify(require('node:child_process').exec);
const timers = require('node:timers/promises');

const log = (type, message) => {
  const utc = (new Date()).toISOString();
  console.log(`[${utc}][${type}] ${message?.trim()}`);
};

const run = async (command, interval, user) => {
  while (true) {
    try {
      const infoline = `${user.uid}:${user.gid} ${command}`;
      log('START', infoline);
      const content = await exec(command, { 
        uid: user.uid,
        gid: user.gid,
        env: { 
          HOME: user.home
        }
      });
      if (content.stdout) {
        log('STDOUT', content.stdout);
      }
      if (content.stderr) {
        log('STDERR', content.stderr);
      }
      log('END', infoline);
    } catch (err) {
      log('ERROR', err.stack || err.message || err)
    }
    await timers.setTimeout(interval);
  }
};

const every = {
  seconds: n => n * 1000,
  minutes: n => n * 60 * 1000,
  hours:   n => n * 60 * 60 * 1000
};

const users = {
  igor: { uid: 1000, gid: 1000, home: '/home/igor' },
  root: { uid: 0,    gid: 0,    home: '/root' }
};

// root
run('/home/igor/arch/scripts/fstrim.sh', every.hours(6), users.root);
run('/home/igor/arch/scripts/cifs.sh', every.seconds(20), users.root);

// igor
run('/home/igor/arch/scripts/dpms.sh', every.minutes(5), users.igor);
run('/home/igor/arch/scripts/updates.sh', every.minutes(5), users.igor);

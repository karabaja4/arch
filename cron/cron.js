import * as std from 'std';
import * as os from 'os';
import * as log from './log.js';

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
    user: users.root
  },
  {
    id: 'dpms',
    command: '/home/igor/arch/scripts/dpms.sh',
    interval: every.minutes(5),
    user: users.igor
  },
  {
    id: 'updates',
    command: '/home/igor/arch/scripts/updates.sh',
    interval: every.minutes(5),
    user: users.igor
  }
];

const home = std.getenv('HOME') || '/root';
const crondir = `${home}/.local/share/cron`;

const getLastRunTimePath = (id) => `${crondir}/${id}.lrt`;

const getLastRunTime = (id) => {
  const filepath = getLastRunTimePath(id);
  const content = std.loadFile(filepath);   // returns null if missing
  if (content === null) {
    log.push(id, 'LRT', `Last run time for ${id} was not found.`);
    return 0;
  }
  const result = parseInt(content.trim(), 10);
  if (Number.isInteger(result)) {
    return result;
  }
  log.push(id, 'LRT', `Last run time for ${id} is invalid.`);
  return 0;
};

const setLastRunTime = (id, ts) => {
  const filepath = getLastRunTimePath(id);
  const f = std.open(filepath, 'w');
  if (f) {
    f.puts(ts.toString());
    f.close();
  }
};

const readFdAsync = (fd) => new Promise((resolve) => {
  const chunks = [];
  const buf = new ArrayBuffer(4096);
  os.setReadHandler(fd, () => {
    const n = os.read(fd, buf, 0, buf.byteLength);
    if (n > 0) {
      chunks.push(String.fromCharCode(...new Uint8Array(buf, 0, n)));
    } else {
      os.setReadHandler(fd, null);
      os.close(fd);
      resolve(chunks.join(''));
    }
  });
});

const execCommand = (command, uid, env) => {
  
  const stdoutPipe = os.pipe();
  const stderrPipe = os.pipe();

  if (!stdoutPipe || !stderrPipe) {
    throw new Error('Failed to create pipes');
  }

  const [stdoutRead, stdoutWrite] = stdoutPipe;
  const [stderrRead, stderrWrite] = stderrPipe;

  const pid = os.exec(
    [command],
    {
      block: false,
      usePath: false,
      uid: uid,
      gid: uid,
      env: env,
      stdout: stdoutWrite,
      stderr: stderrWrite,
    }
  );

  os.close(stdoutWrite);
  os.close(stderrWrite);

  return Promise.all([
    readFdAsync(stdoutRead),
    readFdAsync(stderrRead),
  ]).then(([stdout, stderr]) => {
    const [, status] = os.waitpid(pid, 0);
    const exitCode = (status >> 8) & 0xff;
    return { stdout, stderr, exitCode };
  });
};

const formatDuration = (ms) => {
  const s = 1000;
  const m = s * 60;
  const h = m * 60;
  const d = h * 24;
  const dv = Math.floor(ms / d);
  const hv = Math.floor((ms % d) / h);
  const mv = Math.floor((ms % h) / m);
  const sv = Math.floor((ms % m) / s);
  return [dv && `${dv}d`, hv && `${hv}h`, mv && `${mv}m`, sv && `${sv}s`]
    .filter(Boolean).join('') || '0s';
};

const run = async (job, wait) => {
  
  if (wait > 0) {
    log.push(job.id, 'RUN', `Job waiting for ${formatDuration(wait)}`);
    await os.sleepAsync(wait);
  } else {
    log.push(job.id, 'RUN', 'Job is overdue or has never run, starting immediately.');
  }

  try {
    log.push(job.id, 'START', `(UID: ${job.user.uid}) ${job.command}`);

    const env = {
      USER:  job.user.name,
      HOME:  job.user.home,
      SHELL: '/bin/sh',
      PATH:  std.getenv('PATH') || '/usr/local/sbin:/usr/local/bin:/usr/bin'
    };

    const content = await execCommand(job.command, job.user.uid, env);

    if (content.stdout) {
      log.push(job.id, 'STDOUT', content.stdout);
    }
    if (content.stderr) {
      log.push(job.id, 'STDERR', content.stderr);
    }

    log.push(job.id, 'END', `Job ended with exit code ${content.exitCode}.`);
  } catch (err) {
    log.push(job.id, 'ERROR', err);
  }

  setLastRunTime(job.id, Date.now());
  os.setTimeout(() => run(job, job.interval), 0);
};

const mkdirp = (dirpath) => {
  const parts = dirpath.split('/').filter(Boolean);
  let current = '';
  for (const part of parts) {
    current += '/' + part;
    const ret = os.mkdir(current, 0o755);
    // -17 is -EEXIST; anything else is a real error
    if (ret !== 0 && ret !== -17) {
      throw new Error(`mkdir failed for ${current}: error ${ret}`);
    }
  }
};

const main = async () => {
  try {
    mkdirp(crondir);
    for (const job of jobs) {
      const lastRunTime = getLastRunTime(job.id);
      const elapsed = (lastRunTime === 0) ? Infinity : (Date.now() - lastRunTime);
      const wait = (elapsed >= job.interval) ? 0 : (job.interval - elapsed);
      run(job, wait);
    }
  } catch (err) {
    log.push('main', 'ERROR', err);
    log.close();
    std.exit(1);
  }
};

const shutdown = () => {
  log.push('main', 'SHUTDOWN', 'Shutting down, goodbye.');
  log.close();
  console.log('Exiting.');
  std.exit(0);
};

os.signal(os.SIGINT, shutdown);
os.signal(os.SIGTERM, shutdown);

const SIGHUP = 1;
os.signal(SIGHUP, shutdown);

main();

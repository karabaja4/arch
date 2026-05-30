import * as std from 'std';

const logpath = '/var/log/cron.log';
const logfile = std.open(logpath, 'a');

const unpack = (err) => {
  try {
    if (err === null || err === undefined) return '';
    if (err instanceof Error) {
      return (err.stack || err.message || String(err)).toString().trim();
    }
    return String(err).trim();
  } catch {
    return '(unpack error)';
  }
};

const push = (source, type, message) => {
  const utc = (new Date()).toISOString();
  const formatted = `[${utc}][${source}][${type}] ${unpack(message)}`;
  console.log(formatted);
  if (logfile) {
    logfile.puts(`${formatted}\n`);
    logfile.flush();
  }
};

const close = () => {
  if (logfile) {
    logfile.flush();
    logfile.close();
  }
};

if (!logfile) {
  push('log', 'ERROR', `Cannot open ${logpath} for writing.`);
}

export { push, close };

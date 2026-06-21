import * as std from 'std';

const logpath = '/var/log/cron.log';
let writable = true;

const unpack = (err) => {
  try {
    if (err === null || err === undefined) return '';
    if (err instanceof Error) {
      return [err.message || String(err), err.stack].filter(Boolean).join('\n').trim();
    }
    return String(err).trim();
  } catch {
    return '(unpack error)';
  }
};

const push = (source, type, message) => {
  const utc = (new Date()).toISOString();
  const formatted = unpack(message).split('\n')
    .map(line => `[${utc}][${source}][${type}] ${line?.trim()}`)
    .join('\n');
  console.log(formatted);
  if (writable) {
    const logfile = std.open(logpath, 'a');
    if (logfile) {
      logfile.puts(`${formatted}\n`);
      logfile.close();
    } else {
      writable = false;
      push('log', 'ERROR', `Cannot open ${logpath} for writing.`);
    }
  }
};

export { push };

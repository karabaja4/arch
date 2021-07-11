const disk = require('diskusage');
const threads = require('worker_threads');
const timers = require('timers/promises');

const get = async () => {
  try {
    const info = await disk.check('/home/igor/_private');
    const available = info.available / 1024;
    const total = info.total / 1024;
    const used = total - available - (321121 * 4) - 16384;
    const result = {
      perc: Math.round((used / total) * 100).toString(),
      used: `${(used / (1024 * 1024)).toFixed(2)} GiB`,
      size: `${(total / (1024 * 1024)).toFixed(2)} GiB`,
    };
    threads.parentPort.postMessage(result);
  } catch {}
}

const main = async () => {
  while (!threads.isMainThread) {
    await get();
    await timers.setTimeout(30 * 1000);
  }
}

main();

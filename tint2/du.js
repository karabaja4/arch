const disk = require('diskusage');
const wt = require('worker_threads');
const wd = wt.workerData;
const util = require('util');
const sleep = util.promisify(setTimeout);

const get = async (path, reserved) => {
  try {
    const info = await disk.check(path);
    const available = info.available / 1024;
    const total = info.total / 1024;
    const used = total - available - (reserved * 4) - 16384;
    wt.parentPort.postMessage({ path, total, used, available });
  } catch {}
}

const main = async (path, reserved) => {
  while (true) {
    await get(path, reserved);
    await sleep(30 * 1000);
  }
}

main(wd.path, wd.reserved);

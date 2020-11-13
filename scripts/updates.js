const util = require('util');
const fs = require('fs');
const exec = util.promisify(require('child_process').exec);
const sleep = util.promisify(setTimeout);

const log = async (tag, msg) => {
  console.log(`[${(new Date()).toISOString()}][${tag}]: ${msg}`);
};

const write = async (text) => {
  const filepath = "/tmp/update_count"
  await fs.promises.writeFile(filepath, `${text}`);
  await fs.promises.chmod(filepath, 0o666);
}

const run = async () => {
  while (true) {
    try {
      const result = await exec('checkupdates');
      const count = result.stdout.trim().split(/\r\n|\r|\n/).length;
      write(count);
      return 0;
    } catch (e) {
      // exit code 2 means no packages to update
      if (e.code === 2 && !e.stdout && !e.stderr) {
        write(0);
        return e.code;
      }
      write('-');
      log('error', `failed (${e.code}), retrying`);
      await sleep(1000);
    }
  }
}

const main = async () => {
  const code = await run();
  log('info', `exited (${code})`);
}

main();
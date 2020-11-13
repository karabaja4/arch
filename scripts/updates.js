const util = require('util');
const fs = require('fs');
const exec = util.promisify(require('child_process').exec);

const write = async (text) => {
  const filepath = "/tmp/update_count"
  await fs.promises.writeFile(filepath, `${text}`);
  await fs.promises.chmod(filepath, 0o666);
}

const main = async () => {
  let code = 0;
  try {
    const result = await exec('checkupdates');
    const count = result.stdout.trim().split(/\r\n|\r|\n/).length;
    write(count);
  } catch (e) {
    const zero = e.code === 2 && !e.stdout && !e.stderr;
    write(zero ? '0' : '-');
    code = e.code;
  }
  console.log(`exited (${code})`);
}

main();
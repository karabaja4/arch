const fs = require('node:fs');
const readline = require('node:readline');
const timers = require('node:timers/promises');
const keys = require('./keys');
const log = require('./log');
const config = require('./config').get();

const arg = process.argv.slice(2)[0];
if (!['auto', 'manual'].includes(arg)) {
  log.fatal('need auto or manual');
};

log.success('Hi.');

const send = async (data) => {
  const hidPath = '/dev/hidg0';
  try {
    await fs.promises.writeFile(hidPath, data);
  } catch (e) {
    log.error(`Error writing to ${hidPath}: ${e.message}`);
  }
};

const writeSequence = async (keyInfo) => {
  if (keyInfo) {
    const keyName = keyInfo.name || keyInfo.sequence;
    const ctrl = keyInfo.ctrl;
    const shift =  keyInfo.shift;
    const alt = keyInfo.meta && keyName !== 'escape'; // for some reason escape comes with alt pressed
    // exit on ctrl-c
    if ((keyName?.toLowerCase() === 'c') && (ctrl === true)) {
      log.success('Bye.');
      process.exit(0);
    }
    const message = (ctrl ? 'CTRL+' : '') + (shift ? 'SHIFT+' : '') + (alt ? 'ALT+' : '') + keyName
    log.info(`Key pressed: '${message}'`);
    const keySequence = keys.getKeySequence(keyName, ctrl, shift, alt);
    const releaseSequence = keys.getReleaseSequence();
    if (keySequence && releaseSequence) {
      await send(keySequence);
      await send(releaseSequence);
    } else {
      log.error(`No sequence mapping for: ${keyName}`);
    }
  }
};

// manual typing from stdin
if (arg === 'manual') {
  readline.emitKeypressEvents(process.stdin);
  if (process.stdin.setRawMode != null) {
    process.stdin.setRawMode(true);
  }
  process.stdin.on('keypress', async (str, keyInfo) => {
    await writeSequence(keyInfo);
  });
}

// auto typing predefined values
if (arg === 'auto') {
  
  // values
  const text1 = config.username;
  const text2 = config.password;
  
  const main = async () => {
    const writeAuto = async (keyName) => {
      if (keyName) {
        await writeSequence({
          name: keyName.toLowerCase(),
          ctrl: false,
          meta: false,
          shift: (keyName.length === 1) && (/^[A-Z]+$/.test(keyName))
        });
      }
    };
    const sleep = async (interval) => {
      await timers.setTimeout(interval);
    };
    
    // wakeup
    await writeAuto("escape");
    await sleep(5000);
    
    // text1
    for (let i = 0; i < text1.length; i++) {
      await writeAuto(text1[i]);
      await sleep(300);
    }
    
    // tab
    await sleep(2000);
    await writeAuto("tab");
    await sleep(2000);
    
    // text2
    for (let i = 0; i < text2.length; i++) {
      await writeAuto(text2[i]);
      await sleep(300);
    }
    
    // enter
    await sleep(2000);
    await writeAuto("return");
    
    log.success('Bye.');
  };
  
  main();
}

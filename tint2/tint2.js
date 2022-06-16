const timers = require('timers/promises');
const fs = require('fs');
const WebSocket = require('ws');
const dayjs = require('dayjs');
const os = require('os');
const path = require('path');

const data = {};

const colors = {
  gray: '#757575',
  red: '#FF6E40',
  yellow: '#EEFF41',
  green: '#69F0AE'
};

const fonts = {
  awesome: 'Font Awesome 5 Free', // ttf-font-awesome
  flaticon: 'Flaticon'            // ln -s /home/igor/arch/conky/openlogos.ttf /usr/share/fonts/openlogos.ttf
}

const icons = {
  netdown: '',
  netup: '',
  ping: '',
  cpu: '',
  mem: '',
  ssd: '',
  linode: '',
  disk: '',
  trenddown: '',
  trendup: '',
  clock: ''
};

// activity color
const colorize1 = (value) => {
  if (value !== 0 && !value) return colors.gray;
  if (value > 5) return colors.green;
  return colors.gray;
};

// load color
const colorize2 = (value) => {
  if (value !== 0 && !value) return colors.gray;
  if (value > 80) return colors.red;
  if (value > 40) return colors.yellow;
  return colors.green;
};

const span = (font, size, rise, colorize, icon, name, format, values, cidx) => {
  let text = `${name}: N/A`;
  let color = colors.gray;
  if (values.every(x => x !== undefined && x !== null)) {
    text = `${name}: ${format}`;
    for (let i = 0; i < values.length; i++) {
      text = text.replace(`$${i}`, values[i]);
    }
    color = colorize(values[cidx]);
  }
  return `<span font_family="${font}" size="${size}" rise="${rise}" foreground="${color}">${icon}</span>  ${text}          `;
};

const print = async () => {
  let text = '';
  text += span(fonts.flaticon, 7500, 100, colorize1, icons.netdown, 'DWL', '$0 KB', [ 
    data?.conky?.net?.down // 0
  ], 0);
  text += span(fonts.flaticon, 7500, 100, colorize1, icons.netup, 'UPL', '$0 KB', [
    data?.conky?.net?.up // 0
  ], 0);
  text += span(fonts.awesome, 7500, 100, colorize2, icons.ping, 'PNG', '$0 ms', [
    data?.ws?.ping // 0
  ], 0);
  text += span(fonts.flaticon, 5000, 1000, colorize2, icons.cpu, 'CPU', '$0% ($1 MHz, $2°C)', [
    data?.conky?.cpu?.perc, // 0
    data?.conky?.cpu?.freq, // 1
    data?.conky?.cpu?.temp // 2
  ], 0);
  text += span(fonts.flaticon, 7500, 100, colorize2, icons.mem, 'RAM', '$0B / $1B', [
    data?.conky?.mem?.used, // 0
    data?.conky?.mem?.max, // 1
    data?.conky?.mem?.perc // 2
  ], 2);

  const root = '/';
  const lino = '/home/igor/_private';
  const disk = '/home/igor/_disk';

  // used + available + (reserved_root * 4) + reserved_clusters = 1K-blocks
  const reserved = {
    root: (3039974 * 4) + 16384,
    disk: (24418918 * 4) + 16384,
    linode: (321123 * 4) + 16384
  }

  const rootAvailable = (data?.mounts?.[root] && data?.df?.[root]?.used && data?.df?.[root]?.total) || null;
  const diskAvailable = (data?.mounts?.[disk] && data?.df?.[disk]?.used && data?.df?.[disk]?.total) || null;
  const linoAvailable = (data?.mounts?.[lino] && data?.df?.[lino]?.used && data?.df?.[lino]?.total) || null;

  // root
  text += span(fonts.flaticon, 7500, 100, colorize2, icons.ssd, 'SSD', '$1 GB / $2 GB', [
    rootAvailable,                                                                                              // 0
    rootAvailable && Math.floor((data.df[root].used / 1024) / 1024),                                              // 1
    rootAvailable && Math.floor(((data.df[root].total - reserved.root) / 1024) / 1024),                           // 2
    rootAvailable && ((data.df[root].used / (data.df[root].total - reserved.root)) * 100)                       // 3
  ], 3);

  // disk
  text += span(fonts.awesome, 7500, 100, colorize2, icons.disk, 'EDD', '$1 GB / $2 GB', [
    diskAvailable,                                                                                              // 0
    diskAvailable && Math.floor((data.df[disk].used / 1024) / 1024),                                              // 1
    diskAvailable && Math.floor(((data.df[disk].total - reserved.disk) / 1024) / 1024),                           // 2
    diskAvailable && ((data.df[disk].used / (data.df[disk].total - reserved.disk)) * 100)                       // 3
  ], 3);

  // linode, samba adds reserved space to used
  text += span(fonts.awesome, 7000, 100, colorize2, icons.linode, 'LND', '$1 GB / $2 GB', [
    linoAvailable,                                                                                              // 0
    linoAvailable && Math.floor(((data.df[lino].used - reserved.linode) / 1024) / 1024),                          // 1
    linoAvailable && Math.floor(((data.df[lino].total - reserved.linode) / 1024) / 1024),                         // 2
    linoAvailable && (((data.df[lino].used - reserved.linode) / (data.df[lino].total - reserved.linode)) * 100) // 3
  ], 3);

  text += span(fonts.awesome, 7500, 100, colorize1, icons.clock, 'CLK', '$0', [
    dayjs().format('dddd, MMMM, DD.MM.YYYY. HH:mm:ss') // 0
  ], 0);
  if (text) {
    console.log(text.trim());
  }
}

const conky = async () => {
  while (true) {
    try {
      const content = await fs.promises.readFile('/tmp/conky-tint2.json', 'utf8');
      if (content) {
        data.conky = JSON.parse(content.replaceAll(/[\t\n\r]/gm, ''));
      }
    } catch (e) {}
    await timers.setTimeout(1000);
  }
}

const mounts = async () => {
  while (true) {
    try {
      const content = await fs.promises.readFile('/proc/mounts', 'utf8');
      if (content) {
        const result = {};
        const lines = content.trim().split('\n');
        for (let i = 0; i < lines.length; i++) {
          const line = lines[i];
          const parts = line.split(' ');
          result[parts[1]] = parts[0];
        }
        data.mounts = result;
      }
    } catch (e) {}
    await timers.setTimeout(5000);
  }
}

const ping = () => {
  const ticks = () => process.hrtime.bigint();
  const ws = new WebSocket('wss://avacyn.aerium.hr/ping');
  const timeout = setTimeout(() => {
    ws.terminate();
  }, 5000);
  let interval = null;
  ws.on('open', () => {
    interval = setInterval(() => {
      ws.send(ticks().toString());
    }, 1000);
  });
  ws.on('message', (inc) => {
    const end = ticks();
    timeout.refresh();
    const obj = JSON.parse(inc);
    const start = BigInt(obj.message);
    const nano = end - start;
    data.ws = {
      ping: parseInt(parseFloat(nano) / (1000 * 1000))
    }
  });
  ws.on('error', () => {});
  ws.on('close', () => {
    clearInterval(interval);
    clearTimeout(timeout);
    delete data.ws;
    setTimeout(() => {
      ping(); // ws crashed
    }, 5000);
  });
}

const df = async () => {
  while (true) {
    try {
      const file = path.join(os.homedir(), '.local/share/diskusage/df');
      const content = await fs.promises.readFile(file, 'utf8');
      if (content) {
        const result = {};
        const lines = content.trim().split('\n');
        for (let i = 1; i < lines.length; i++) {
          const line = lines[i];
          const parts = line.split(/\s+/);
          result[parts[5]] = {
            total: parseInt(parts[1]),
            used: parseInt(parts[2]),
            available: parseInt(parts[3])
          };
        }
        data.df = result;
      }
    } catch (e) {}
    await timers.setTimeout(60000);
  }
}

const main = async () => {
  while (true) {
    await print();
    await timers.setTimeout(1000);
  }
}

conky();
mounts();
ping();
df();
main();

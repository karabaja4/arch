const timers = require('node:timers/promises');
const fs = require('node:fs');
const WebSocket = require('ws');
const dayjs = require('dayjs');
const util = require('node:util');
const execFile = util.promisify(require('node:child_process').execFile);
const os = require('node:os');
const path = require('node:path');

const data = {};

const colors = {
  gray: '#757575',
  red: '#FF6E40',
  yellow: '#EEFF41',
  green: '#69F0AE'
};

const fonts = {
  awesome: 'Font Awesome 6 Free', // ttf-font-awesome
  flaticon: 'Flaticon'            // ln -s /home/igor/arch/conky/flaticon.ttf /usr/share/fonts/flaticon.ttf
}

const icons = {
  netdown: '',
  netup: '',
  ping: '',
  cpu: '',
  mem: '',
  linode: '',
  trenddown: '',
  trendup: '',
  clock: ''
};

// disks
const disks = [
  {
    mountpoint: '/',
    font: fonts.flaticon,
    icon: '',
    label: 'SSD'
  },
  {
    mountpoint: '/home/igor/_disk',
    font: fonts.awesome,
    icon: '',
    label: 'EDD'
  }
];

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
  if (values.length > 0 && values.every(x => x !== undefined && x !== null)) {
    text = `${name}: ${format}`;
    for (let i = 0; i < values.length; i++) {
      text = text.replace(`$${i}`, values[i]);
    }
    if (colorize) {
      color = colorize(values[cidx]);
    }
  }
  return `<span font_family="${font}" size="${size}" rise="${rise}" foreground="${color}">${icon}</span>  ${text}          `;
};

const norm = (input) => {
  if (input === null || input === undefined) {
    return input;
  }
  const unit = input.slice(-1);
  const num = input.slice(0, -1);
  return `${num} ${unit}B`;
}

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
  text += span(fonts.flaticon, 7500, 100, colorize2, icons.mem, 'RAM', '$0 / $1', [
    norm(data?.conky?.mem?.used), // 0
    norm(data?.conky?.mem?.max), // 1
    data?.conky?.mem?.perc // 2
  ], 2);

  for (let i = 0; i < disks.length; i++) {
    const item = disks[i];
    const avail = data?.mounts?.[item.mountpoint] &&
                  data?.du?.[item.mountpoint]?.total &&
                  data?.du?.[item.mountpoint]?.used &&
                  data?.du?.[item.mountpoint]?.available || null;
    const res = [];
    if (avail) {
      const dfi = data.du[item.mountpoint];
      const used  = dfi.used;
      const total = used + dfi.available;
      res[0] = Math.floor((used / 1024) / 1024);
      res[1] = Math.floor((total / 1024) / 1024);
      res[2] = (used / total) * 100;
    }
    text += span(item.font, 7500, 100, colorize2, item.icon, item.label, '$0 GB / $1 GB', res, 2);
  }

  let clk = dayjs().format('dddd, MMMM, DD.MM.YYYY. HH:mm:ss');
  if (data?.weather?.temp) {
    clk += `, ${data.weather.temp}°C`;
  }

  // clock
  text += span(fonts.awesome, 7500, 100, null, icons.clock, 'CLK', '$0', [
    clk // 0
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
        data.conky = JSON.parse(content);
      }
    } catch {}
    await timers.setTimeout(1000);
  }
}

const mounts = async () => {
  while (true) {
    try {
      const result = {};
      const content = await fs.promises.readFile('/proc/mounts', 'utf8');
      if (content) {
        const lines = content.trim().split('\n');
        for (let i = 0; i < lines.length; i++) {
          const line = lines[i];
          const parts = line.split(' ');
          result[parts[1]] = parts[0];
        }
      }
      data.mounts = result;
    } catch {}
    await timers.setTimeout(10 * 1000);
  }
}

const ping = () => {
  const ticks = () => process.hrtime.bigint();
  const ws = new WebSocket('wss://avacyn.radiance.hr/ping');
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

const diskusage = async () => {
  const dudir = path.join(os.homedir(), '.local/share/diskusage');
  await fs.promises.mkdir(dudir, { recursive: true });
  const dufile = path.join(dudir, 'du.json');
  while (true) {
    try {
      let result = {};
      // fill in previous mountpoint diskusages
      try {
        const content = await fs.promises.readFile(dufile, 'utf8');
        result = JSON.parse(content);
      } catch {}
      const proc = await execFile('lsblk', ['--output', 'UUID,PATH,MOUNTPOINT,FSAVAIL,FSSIZE,FSUSED,TYPE', '--json', '--bytes']);
      const parsed = JSON.parse(proc.stdout);
      if (parsed.blockdevices) {
        for (let i = 0; i < parsed.blockdevices.length; i++) {
          const device = parsed.blockdevices[i];
          if (device.mountpoint && device.fssize && typeof device.fssize === 'number') {
            result[device.mountpoint] = {
              total: Math.floor(device.fssize / 1024),
              used: Math.floor(device.fsused / 1024),
              available: Math.floor(device.fsavail / 1024)
            };
          }
        }
      }
      await fs.promises.writeFile(dufile, JSON.stringify(result, null, 4));
      data.du = result;
    } catch {}
    await timers.setTimeout(5 * 60 * 1000);
  }
}

const weather = async () => {
  const station = 'Zagreb-Maksimir';
  const url = 'https://vrijeme.hr/hrvatska_n.xml';
  while (true) {
    let temp = null;
    try {
      const response = await fetch(url, { method: 'GET' });
      if (response.status === 200) {
        const data = await response.text();
        const regex = new RegExp(`<GradIme>${station}<\/GradIme>.+?<Temp>(.+?)<\/Temp>`, 's');
        temp = data.match(regex);
      }
    } catch {}
    data.weather = temp && temp[1] && (temp[1].length < 10) ? { temp: temp[1].trim().split('.')[0] } : null;
    await timers.setTimeout(60 * 60 * 1000);
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
diskusage();
weather();
main();

const timers = require('node:timers/promises');
const fs = require('node:fs');
const util = require('node:util');
const os = require('node:os');
const path = require('node:path');
const cp = require('node:child_process');
const execFile = util.promisify(cp.execFile);

const JSONStream = require('JSONStream');
const WebSocket = require('ws');
const dayjs = require('dayjs');

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
};

const mkicon = (char, font, size, rise) => {
  return {
    char: char,
    font: font,
    size: size,
    rise: rise
  };
};

const icons = {
  netdown: mkicon('', fonts.flaticon, 7500, 100),
  netup: mkicon('', fonts.flaticon, 7500, 100),
  ping: mkicon('', fonts.awesome, 7500, 100),
  cpu: mkicon('', fonts.flaticon, 5000, 1000),
  mem: mkicon('', fonts.flaticon, 7500, 100),
  clock: mkicon('', fonts.awesome, 7500, 100),
  ssd: mkicon('', fonts.awesome, 7500, 100),
  mmc: mkicon('', fonts.flaticon, 7500, 100)
};

const mkdisk = (mountpoint, icon, label) => {
  return {
    mountpoint: mountpoint,
    icon: icon,
    label: label
  }
};

// disks
const disks = [
  mkdisk('/', icons.ssd, 'SSD'),
  mkdisk('/home/igor/_mmc', icons.mmc, 'MMC')
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

// battery color
const colorize3 = (value) => {
  if (value !== 0 && !value) return colors.gray;
  if (value < 20) return colors.red;
  if (value < 60) return colors.yellow;
  return colors.green;
};

const span = (icon, colorize, name, format, values, cidx) => {
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
  return `<span font_family="${icon.font}" size="${icon.size}" rise="${icon.rise}" foreground="${color}">${icon.char}</span>  <span rise="-1000">${text}</span>          `;
};

const norm = (input) => {
  if (input === null || input === undefined) {
    return input;
  }
  const unit = input.slice(-1);
  const num = input.slice(0, -1);
  return `${num} ${unit}B`;
};

const print = () => {
  let text = '';
  text += span(icons.netdown, colorize1, 'DWL', '$0 KB', [ 
    data?.conky?.net?.down // 0
  ], 0);
  text += span(icons.netup, colorize1, 'UPL', '$0 KB', [
    data?.conky?.net?.up // 0
  ], 0);
  text += span(icons.ping, colorize2, 'PNG', '$0 ms', [
    data?.ws?.ping // 0
  ], 0);
  text += span(icons.cpu, colorize2, 'CPU', '$0% ($1 MHz, $2°C)', [
    data?.conky?.cpu?.perc, // 0
    data?.conky?.cpu?.freq, // 1
    data?.conky?.cpu?.temp // 2
  ], 0);
  text += span(icons.mem, colorize2, 'RAM', '$0 / $1', [
    norm(data?.conky?.mem?.used), // 0
    norm(data?.conky?.mem?.max), // 1
    data?.conky?.mem?.perc // 2
  ], 2);

  for (let i = 0; i < disks.length; i++) {
    const disk = disks[i];
    const avail = data?.mounts?.[disk.mountpoint] &&
                  data?.du?.[disk.mountpoint]?.total &&
                  data?.du?.[disk.mountpoint]?.used &&
                  data?.du?.[disk.mountpoint]?.available || null;
    const res = [];
    if (avail) {
      const dfi = data.du[disk.mountpoint];
      const used  = dfi.used;
      const total = used + dfi.available;
      res[0] = Math.floor((used / 1024) / 1024);
      res[1] = Math.floor((total / 1024) / 1024);
      res[2] = (used / total) * 100;
    }
    text += span(disk.icon, colorize2, disk.label, '$0 GB / $1 GB', res, 2);
  }
  
  // battery
  text += span(icons.cpu, colorize3, 'BAT', '$0% ($1)', [
    data?.conky?.bat?.perc, // 0
    data?.conky?.bat?.time || 'charged' // 1
  ], 0);

  let clk = dayjs().format('dddd, MMMM, DD.MM.YYYY. HH:mm:ss');
  if (data?.weather?.temp) {
    clk += `, ${data.weather.temp}°C`;
  }

  // clock
  text += span(icons.clock, null, 'CLK', '$0', [
    clk // 0
  ], 0);
  if (text) {
    console.log(text.trim());
  }
};

const conky = async () => {
  const conkyrc = path.join(__dirname, 'conkyrc-tint2');
  const instance = cp.spawn('conky', ['-q', '-c', conkyrc]);
  instance.stdout.pipe(JSONStream.parse()).on('data', (result) => {
    data.conky = result;
    print();
  }); 
};

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
    // increase timeout if everything is mounted
    let timeout = 600;
    for (let i = 0; i < disks.length; i++) {
      if (!data?.mounts?.[disks[i].mountpoint]) {
        timeout = 10;
        break;
      }
    }
    await timers.setTimeout(timeout * 1000);
  }
};

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
};

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
          if (device.mountpoint && device.fssize && typeof device.fssize === 'number' && device.type !== 'loop') {
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
};

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
    data.weather = temp && temp[1] && (temp[1].length < 10) ? { temp: Math.round(temp[1].trim()).toString() } : null;
    await timers.setTimeout(data.weather ? (60 * 60 * 1000) : (60 * 1000));
  }
};

mounts();
ping();
diskusage();
weather();
conky(); // conky calls print() on each update event

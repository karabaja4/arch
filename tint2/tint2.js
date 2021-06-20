const util = require('util');
const sleep = util.promisify(setTimeout);
const { spawn } = require('child_process');

const files = {
  config: '/home/igor/arch/conky/conkyrc-tint2'
}

const colors = {
  gray: '#757575',
  red: '#FF6E40',
  yellow: '#EEFF41',
  green: '#69F0AE'
};

const fonts = {
  awesome: 'Font Awesome 5 Free',
  ionicons: 'Ionicons',
  nerd: 'Symbols Nerd Font',
  flaticon: 'Flaticon'
}

const icons = {
  netdown: '',
  netup: '',
  ping: '',
  cpu: '',
  mem: '',
  ssd: '',
  cls: '',
  edd: '',
  trenddown: '',
  trendup: '',
  clock: ''
};

const span = (font, size, rise, color, icon, text) => {
  return `<span font_family="${font}" size="${size}" rise="${rise}" foreground="${color}">${icon}</span>  ${text}          `;
};

const nc = (value) => {
  if (value !== 0 && !value) return colors.gray;
  if (value > 5) return colors.green;
  return colors.gray;
};

const oc = (value) => {
  if (value !== 0 && !value) return colors.gray;
  if (value > 80) return colors.red;
  if (value > 30) return colors.yellow;
  return colors.green;
};

const fixunits = (unit) => {
  return unit.replace('GiB', 'GB').replace('MiB', 'MB').replace('KiB', 'KB');
};

const print = async () => {

  const data = JSON.parse(store.conky.data);
  const ms = parseInt(store.ping.data);

  let text = '';

  text += span(fonts.flaticon, 7500, 100, nc(data.net.down), icons.netdown, `DWL: ${data.net.down} KB`);
  text += span(fonts.flaticon, 7500, 100, nc(data.net.up),   icons.netup,   `UPL: ${data.net.up} KB`);
  text += span(fonts.awesome,  7500, 100, oc(ms),            icons.ping,    `PNG: ${ms ? `${ms} ms` : 'timeout'}`);

  text += span(fonts.nerd,     7000, 100, oc(data.cpu.perc), icons.cpu,     `CPU: ${data.cpu.perc}% (${data.cpu.freq} MHz)`);
  text += span(fonts.flaticon, 7500, 100, oc(data.mem.perc), icons.mem,     `RAM: ${fixunits(data.mem.used)} / ${fixunits(data.mem.max)}`);

  const disktext = (name) => `${name.toUpperCase()}: ${data[name] ? `${fixunits(data[name].used)} / ${fixunits(data[name].size)}` : 'not mounted'}`;
  const diskspan = (font, name, size) => span(font, size, 100, oc(data[name]?.perc), icons[name], disktext(name));

  text += diskspan(fonts.awesome, 'ssd', 7500);
  text += diskspan(fonts.awesome, 'cls', 7000);
  text += diskspan(fonts.awesome, 'edd', 7500);

  text += span(fonts.awesome, 7500, 100, colors.gray, icons.clock, `CLK: ${data.time}`).trimEnd();
  console.log(text);
};

let store = {
  conky: {
    stream: '',
    data: null
  },
  ping: {
    stream: '',
    data: null
  }
}

const parse = async () => {
  const regex = {
    conky: new RegExp(`START_OF_JSON(.*?)END_OF_JSON`),
    ping: new RegExp('.*?time=(\\S+)\\sms\\n')
  }
  const cm = store.conky.stream.match(regex.conky);
  if (cm) {
    store.conky.stream = '';
    store.conky.data = cm[1];
  }
  const pm = store.ping.stream.match(regex.ping);
  if (pm) {
    store.ping.stream = '';
    store.ping.data = pm[1];
  }
};


const exec = (command, options, listener) => {
  store[command].stream = '';
  store[command].data = null;
  const proc = spawn(command, options);
  const timeout = setTimeout(() => {
    proc.kill('SIGINT');
  }, 5000);
  proc.stdout.on('data', (data) => {
    listener(data);
    timeout.refresh();
  });
  proc.on('close', async () => {
    clearTimeout(timeout);
    await sleep(1000);
    exec(command, options, listener);
  });
}

const loop = async () => {
  while (true) {
    await sleep(500);
    await parse();
    if (store.conky.data) {
      await print(store.conky.data, store.ping.data);
    }
  }
};

exec('conky', ['-c', files.config], (data) => {
  store.conky.stream += data.toString().replace(/(\r\n|\n|\r|\t)/gm, '');
});

exec('ping', ['-i', 1, 'linode.aerium.hr'], (data) => {
  store.ping.stream += data.toString();
});

loop();

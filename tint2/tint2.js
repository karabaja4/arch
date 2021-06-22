const { spawn } = require('child_process');
const WebSocket = require('ws');

const colors = {
  gray: '#757575',
  red: '#FF6E40',
  yellow: '#EEFF41',
  green: '#69F0AE'
};

const fonts = {
  awesome: 'Font Awesome 5 Free',
  flaticon: 'Flaticon'
}

const icons = {
  netdown: '',
  netup: '',
  ping: '',
  cpu: '',
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

const print = () => {

  const data = store.conky.data && JSON.parse(store.conky.data);
  const ms = store.ping.data && parseInt(store.ping.data);

  let text = '';

  text += span(fonts.flaticon, 7500, 100,  nc(data.net.down), icons.netdown, `DWL: ${data.net.down} KB`);
  text += span(fonts.flaticon, 7500, 100,  nc(data.net.up),   icons.netup,   `UPL: ${data.net.up} KB`);
  text += span(fonts.awesome,  7500, 100,  oc(ms),            icons.ping,    `PNG: ${ms ? `${ms} ms` : 'timeout'}`);

  text += span(fonts.flaticon, 5000, 1000, oc(data.cpu.perc), icons.cpu,     `CPU: ${data.cpu.perc}% (${data.cpu.freq} MHz)`);
  text += span(fonts.flaticon, 7500, 100,  oc(data.mem.perc), icons.mem,     `RAM: ${fixunits(data.mem.used)} / ${fixunits(data.mem.max)}`);

  const disktext = (name) => `${name.toUpperCase()}: ${data[name] ? `${fixunits(data[name].used)} / ${fixunits(data[name].size)}` : 'not mounted'}`;
  const diskspan = (font, name, size) => span(font, size, 100, oc(data[name]?.perc), icons[name], disktext(name));

  text += diskspan(fonts.awesome, 'ssd', 7500);
  text += diskspan(fonts.awesome, 'cls', 7000);
  text += diskspan(fonts.awesome, 'edd', 7500);

  text += span(fonts.awesome, 7500, 100, colors.gray, icons.clock, `CLK: ${data.time}`).trimEnd();
  console.log(text);
};

const store = {
  conky: {
    stream: '',
    data: null
  },
  ping: {
    data: null
  }
}

const conky = () => {

  const proc = spawn('conky', ['-c', '/home/igor/arch/conky/conkyrc-tint2']);
  const regex = new RegExp(`START_OF_JSON(.*?)END_OF_JSON`);

  proc.stdout.on('data', (data) => {
    store.conky.stream += data.toString().replace(/(\r\n|\n|\r|\t)/gm, '');
    const match = store.conky.stream.match(regex);
    if (match) {
      store.conky.stream = '';
      store.conky.data = match[1];
    }
  });

  proc.on('close', () => {
    store.conky.stream = '';
    store.conky.data = null;
  });

}

const ping = () => {

  const ticks = () => process.hrtime.bigint().toString();
  const ws = new WebSocket('wss://linode.aerium.hr/ping');
  const timeout = setTimeout(() => { ws.terminate(); }, 10000);

  ws.on('open', () => {
    setInterval(() => { ws.send(ticks()); }, 1000);
  });

  ws.on('message', (message) => {
    timeout.refresh();
    const end = BigInt(ticks());
    const start = BigInt(message);
    const nano = end - start;
    store.ping.data = parseFloat(nano) / (1000 * 1000);
  });

  ws.on('error', () => {
    // empty handler because otherwise ws crashes
  });

  ws.on('close', () => {
    clearTimeout(timeout);
    store.ping.data = null;
    setTimeout(() => { ping(); }, 5000);
  });
  
}

conky();
ping();

setInterval(() => {
  print();
}, 500);

// notes:
// printing needs to happen in a separate loop, because conky stdout blocks
// when the internet connection is broken, because of mounted internet shares
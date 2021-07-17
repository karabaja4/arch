const { spawn } = require('child_process');
const WebSocket = require('ws');
const timers = require('timers/promises');

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

  const data = store.conky && JSON.parse(store.conky);
  if (!data) {
    return; // no point without conky
  }

  const ms = store.ping && parseInt(store.ping);

  data.cls = store.cls;

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
  conky: null, // unparsed json
  ping: null,  // float
  cls: null    // object
}

const conky = () => {

  return new Promise((resolve) => {

    const proc = spawn('conky', ['-c', '/home/igor/arch/conky/conkyrc-tint2']);
    const regex = new RegExp(`START_OF_JSON(.*?)END_OF_JSON`);

    let stream = '';
  
    proc.stdout.on('data', (data) => {
      stream += data.toString().replace(/(\r\n|\n|\r|\t)/gm, '');
      const match = stream.match(regex);
      if (match) {
        stream = '';
        store.conky = match[1];
      }
    });
  
    proc.on('close', (code) => {
      store.conky = null;
      resolve(code);
    });

  });

}

const ping = async () => {

  return new Promise((resolve) => {

    const ticks = () => process.hrtime.bigint();
    const ws = new WebSocket('wss://linode.aerium.hr/ping');
  
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
      store.ping = parseFloat(nano) / (1000 * 1000);
      const du = obj.diskusage;
      store.cls = {
        perc: Math.round((du.used / du.total) * 100).toString(),
        used: `${(du.used / (1024 * 1024)).toFixed(2)} GiB`,
        size: `${(du.total / (1024 * 1024)).toFixed(2)} GiB`,
      };
    });
  
    ws.on('error', () => {
      // empty handler because otherwise ws crashes
    });
  
    ws.on('close', (code) => {
      clearInterval(interval);
      clearTimeout(timeout);
      store.ping = null;
      store.cls = null;
      resolve(code);
    });

  });

}

const mainloop = async () => {
  while (true) {
    await print();
    await timers.setTimeout(1000);
  }
}

const pingloop = async () => {
  while (true) {
    await ping();
    await timers.setTimeout(5000);
  }
}

const conkyloop = async () => {
  while (true) {
    await conky();
    await timers.setTimeout(5000);
  }
}

pingloop();
conkyloop();
mainloop();

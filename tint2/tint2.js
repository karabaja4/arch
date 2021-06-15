const util = require('util');
const sleep = util.promisify(setTimeout);
const { spawn } = require('child_process');

const files = {
  config: '/home/igor/arch/conky/conkyrc-tint2'
}

const separators = {
  start: 'START_OF_JSON',
  end: 'END_OF_JSON'
}

const colors = {
  gray: '#757575',
  red: '#FF6E40',
  yellow: '#EEFF41',
  green: '#69F0AE'
};

const icons = {
  netdown: '',
  netup: '',
  cpu: '',
  mem: '',
  ssd: '',
  mmc: '',
  edd: '',
  trenddown: '',
  trendup: '',
  clock: ''
};

const span = (size, rise, color, icon, text) => {
  return `<span font_family="Flaticon" size="${size}" rise="${rise}" foreground="${color}">${icon}</span>  ${text}         `;
};

const nc = (value) => {
  if (value === null || value === undefined) return colors.gray;
  if (value > 5) return colors.green;
  return colors.gray;
};

const oc = (value) => {
  if (value === null || value === undefined) return colors.gray;
  if (value > 80) return colors.red;
  if (value > 30) return colors.yellow;
  return colors.green;
};

const fixunits = (unit) => {
  return unit.replace('GiB', 'GB').replace('MiB', 'MB').replace('KiB', 'KB');
};

const print = async (json) => {
  const data = JSON.parse(json);
  let text = '';

  text += span(8000, 100, nc(data.net.down), icons.netdown, `DWL: ${data.net.down} KB`);
  text += span(8000, 100, nc(data.net.up), icons.netup, `UPL: ${data.net.up} KB`);
  text += span(5000, 1200, oc(data.cpu.perc), icons.cpu, `CPU: ${data.cpu.perc}% (${data.cpu.freq} MHz)`);
  text += span(8000, 100, oc(data.mem.perc), icons.mem, `RAM: ${fixunits(data.mem.used)} / ${fixunits(data.mem.max)}`);

  const disktext = (name) => `${name.toUpperCase()}: ${data[name] ? `${fixunits(data[name].used)} / ${fixunits(data[name].size)}` : 'not mounted'}`;
  const diskspan = (name) => span(8000, 100, oc(data[name]?.perc), icons[name], disktext(name));

  text += diskspan('ssd');
  text += diskspan('mmc');
  text += diskspan('edd');

  text += span(8000, 100, colors.gray, icons.clock, `CLK: ${data.time}`).trimEnd();
  console.log(text);
};

let stream = '';

const pop = async () => {
  var regex = new RegExp(`${separators.start}(.*?)${separators.end}`);
  const match = stream.match(regex);
  if (match) {
    const json = match[1];
    stream = stream.replace(regex, '');
    await print(json);
  }
};

const conky = () => {
  const conky = spawn('conky', ['-c', files.config]);
  conky.stdout.on('data', async (data) => {
    stream += data.toString().replace(/(\r\n|\n|\r|\t)/gm, '');
  });
};

const loop = async () => {
  while (true) {
    await sleep(500);
    await pop();
  }
};

conky();
loop();

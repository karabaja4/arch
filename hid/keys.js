const NULLCHAR = String.fromCharCode(0);
const LSHIFT = String.fromCharCode(0x02);
const CTRLALT = String.fromCharCode(0x05);

const mapArray = [
  
  // lowercase
  { key: 'a', value: NULLCHAR.repeat(2) + String.fromCharCode(0x04) + NULLCHAR.repeat(5) },
  { key: 'b', value: NULLCHAR.repeat(2) + String.fromCharCode(0x05) + NULLCHAR.repeat(5) },
  { key: 'c', value: NULLCHAR.repeat(2) + String.fromCharCode(0x06) + NULLCHAR.repeat(5) },
  { key: 'd', value: NULLCHAR.repeat(2) + String.fromCharCode(0x07) + NULLCHAR.repeat(5) },
  { key: 'e', value: NULLCHAR.repeat(2) + String.fromCharCode(0x08) + NULLCHAR.repeat(5) },
  { key: 'f', value: NULLCHAR.repeat(2) + String.fromCharCode(0x09) + NULLCHAR.repeat(5) },
  { key: 'g', value: NULLCHAR.repeat(2) + String.fromCharCode(0x0a) + NULLCHAR.repeat(5) },
  { key: 'h', value: NULLCHAR.repeat(2) + String.fromCharCode(0x0b) + NULLCHAR.repeat(5) },
  { key: 'i', value: NULLCHAR.repeat(2) + String.fromCharCode(0x0c) + NULLCHAR.repeat(5) },
  { key: 'j', value: NULLCHAR.repeat(2) + String.fromCharCode(0x0d) + NULLCHAR.repeat(5) },
  { key: 'k', value: NULLCHAR.repeat(2) + String.fromCharCode(0x0e) + NULLCHAR.repeat(5) },
  { key: 'l', value: NULLCHAR.repeat(2) + String.fromCharCode(0x0f) + NULLCHAR.repeat(5) },
  { key: 'm', value: NULLCHAR.repeat(2) + String.fromCharCode(0x10) + NULLCHAR.repeat(5) },
  { key: 'n', value: NULLCHAR.repeat(2) + String.fromCharCode(0x11) + NULLCHAR.repeat(5) },
  { key: 'o', value: NULLCHAR.repeat(2) + String.fromCharCode(0x12) + NULLCHAR.repeat(5) },
  { key: 'p', value: NULLCHAR.repeat(2) + String.fromCharCode(0x13) + NULLCHAR.repeat(5) },
  { key: 'q', value: NULLCHAR.repeat(2) + String.fromCharCode(0x14) + NULLCHAR.repeat(5) },
  { key: 'r', value: NULLCHAR.repeat(2) + String.fromCharCode(0x15) + NULLCHAR.repeat(5) },
  { key: 's', value: NULLCHAR.repeat(2) + String.fromCharCode(0x16) + NULLCHAR.repeat(5) },
  { key: 't', value: NULLCHAR.repeat(2) + String.fromCharCode(0x17) + NULLCHAR.repeat(5) },
  { key: 'u', value: NULLCHAR.repeat(2) + String.fromCharCode(0x18) + NULLCHAR.repeat(5) },
  { key: 'v', value: NULLCHAR.repeat(2) + String.fromCharCode(0x19) + NULLCHAR.repeat(5) },
  { key: 'w', value: NULLCHAR.repeat(2) + String.fromCharCode(0x1a) + NULLCHAR.repeat(5) },
  { key: 'x', value: NULLCHAR.repeat(2) + String.fromCharCode(0x1b) + NULLCHAR.repeat(5) },
  { key: 'y', value: NULLCHAR.repeat(2) + String.fromCharCode(0x1c) + NULLCHAR.repeat(5) },
  { key: 'z', value: NULLCHAR.repeat(2) + String.fromCharCode(0x1d) + NULLCHAR.repeat(5) },
  
  // uppercase
  { key: 'A', value: LSHIFT + NULLCHAR + String.fromCharCode(0x04) + NULLCHAR.repeat(5) },
  { key: 'B', value: LSHIFT + NULLCHAR + String.fromCharCode(0x05) + NULLCHAR.repeat(5) },
  { key: 'C', value: LSHIFT + NULLCHAR + String.fromCharCode(0x06) + NULLCHAR.repeat(5) },
  { key: 'D', value: LSHIFT + NULLCHAR + String.fromCharCode(0x07) + NULLCHAR.repeat(5) },
  { key: 'E', value: LSHIFT + NULLCHAR + String.fromCharCode(0x08) + NULLCHAR.repeat(5) },
  { key: 'F', value: LSHIFT + NULLCHAR + String.fromCharCode(0x09) + NULLCHAR.repeat(5) },
  { key: 'G', value: LSHIFT + NULLCHAR + String.fromCharCode(0x0a) + NULLCHAR.repeat(5) },
  { key: 'H', value: LSHIFT + NULLCHAR + String.fromCharCode(0x0b) + NULLCHAR.repeat(5) },
  { key: 'I', value: LSHIFT + NULLCHAR + String.fromCharCode(0x0c) + NULLCHAR.repeat(5) },
  { key: 'J', value: LSHIFT + NULLCHAR + String.fromCharCode(0x0d) + NULLCHAR.repeat(5) },
  { key: 'K', value: LSHIFT + NULLCHAR + String.fromCharCode(0x0e) + NULLCHAR.repeat(5) },
  { key: 'L', value: LSHIFT + NULLCHAR + String.fromCharCode(0x0f) + NULLCHAR.repeat(5) },
  { key: 'M', value: LSHIFT + NULLCHAR + String.fromCharCode(0x10) + NULLCHAR.repeat(5) },
  { key: 'N', value: LSHIFT + NULLCHAR + String.fromCharCode(0x11) + NULLCHAR.repeat(5) },
  { key: 'O', value: LSHIFT + NULLCHAR + String.fromCharCode(0x12) + NULLCHAR.repeat(5) },
  { key: 'P', value: LSHIFT + NULLCHAR + String.fromCharCode(0x13) + NULLCHAR.repeat(5) },
  { key: 'Q', value: LSHIFT + NULLCHAR + String.fromCharCode(0x14) + NULLCHAR.repeat(5) },
  { key: 'R', value: LSHIFT + NULLCHAR + String.fromCharCode(0x15) + NULLCHAR.repeat(5) },
  { key: 'S', value: LSHIFT + NULLCHAR + String.fromCharCode(0x16) + NULLCHAR.repeat(5) },
  { key: 'T', value: LSHIFT + NULLCHAR + String.fromCharCode(0x17) + NULLCHAR.repeat(5) },
  { key: 'U', value: LSHIFT + NULLCHAR + String.fromCharCode(0x18) + NULLCHAR.repeat(5) },
  { key: 'V', value: LSHIFT + NULLCHAR + String.fromCharCode(0x19) + NULLCHAR.repeat(5) },
  { key: 'W', value: LSHIFT + NULLCHAR + String.fromCharCode(0x1a) + NULLCHAR.repeat(5) },
  { key: 'X', value: LSHIFT + NULLCHAR + String.fromCharCode(0x1b) + NULLCHAR.repeat(5) },
  { key: 'Y', value: LSHIFT + NULLCHAR + String.fromCharCode(0x1c) + NULLCHAR.repeat(5) },
  { key: 'Z', value: LSHIFT + NULLCHAR + String.fromCharCode(0x1d) + NULLCHAR.repeat(5) },
  
  // numbers
  { key: '1', value: NULLCHAR.repeat(2) + String.fromCharCode(0x1e) + NULLCHAR.repeat(5) },
  { key: '2', value: NULLCHAR.repeat(2) + String.fromCharCode(0x1f) + NULLCHAR.repeat(5) },
  { key: '3', value: NULLCHAR.repeat(2) + String.fromCharCode(0x20) + NULLCHAR.repeat(5) },
  { key: '4', value: NULLCHAR.repeat(2) + String.fromCharCode(0x21) + NULLCHAR.repeat(5) },
  { key: '5', value: NULLCHAR.repeat(2) + String.fromCharCode(0x22) + NULLCHAR.repeat(5) },
  { key: '6', value: NULLCHAR.repeat(2) + String.fromCharCode(0x23) + NULLCHAR.repeat(5) },
  { key: '7', value: NULLCHAR.repeat(2) + String.fromCharCode(0x24) + NULLCHAR.repeat(5) },
  { key: '8', value: NULLCHAR.repeat(2) + String.fromCharCode(0x25) + NULLCHAR.repeat(5) },
  { key: '9', value: NULLCHAR.repeat(2) + String.fromCharCode(0x26) + NULLCHAR.repeat(5) },
  { key: '0', value: NULLCHAR.repeat(2) + String.fromCharCode(0x27) + NULLCHAR.repeat(5) },
  
  // numbers with shift
  { key: '!', value: LSHIFT + NULLCHAR + String.fromCharCode(0x1e) + NULLCHAR.repeat(5) },
  { key: '"', value: LSHIFT + NULLCHAR + String.fromCharCode(0x1f) + NULLCHAR.repeat(5) },
  { key: '£', value: LSHIFT + NULLCHAR + String.fromCharCode(0x20) + NULLCHAR.repeat(5) },
  { key: '$', value: LSHIFT + NULLCHAR + String.fromCharCode(0x21) + NULLCHAR.repeat(5) },
  { key: '%', value: LSHIFT + NULLCHAR + String.fromCharCode(0x22) + NULLCHAR.repeat(5) },
  { key: '^', value: LSHIFT + NULLCHAR + String.fromCharCode(0x23) + NULLCHAR.repeat(5) },
  { key: '&', value: LSHIFT + NULLCHAR + String.fromCharCode(0x24) + NULLCHAR.repeat(5) },
  { key: '*', value: LSHIFT + NULLCHAR + String.fromCharCode(0x25) + NULLCHAR.repeat(5) },
  { key: '(', value: LSHIFT + NULLCHAR + String.fromCharCode(0x26) + NULLCHAR.repeat(5) },
  { key: ')', value: LSHIFT + NULLCHAR + String.fromCharCode(0x27) + NULLCHAR.repeat(5) },
  
  // chars
  { key: '-', value: NULLCHAR.repeat(2) + String.fromCharCode(0x2d) + NULLCHAR.repeat(5) },
  { key: '=', value: NULLCHAR.repeat(2) + String.fromCharCode(0x2e) + NULLCHAR.repeat(5) },
  { key: '[', value: NULLCHAR.repeat(2) + String.fromCharCode(0x2f) + NULLCHAR.repeat(5) },
  { key: ']', value: NULLCHAR.repeat(2) + String.fromCharCode(0x30) + NULLCHAR.repeat(5) },
  { key: '#', value: NULLCHAR.repeat(2) + String.fromCharCode(0x32) + NULLCHAR.repeat(5) }, // Keyboard Non-US #
  { key: ';', value: NULLCHAR.repeat(2) + String.fromCharCode(0x33) + NULLCHAR.repeat(5) },
  { key: '\'', value: NULLCHAR.repeat(2) + String.fromCharCode(0x34) + NULLCHAR.repeat(5) },
  { key: '`', value: NULLCHAR.repeat(2) + String.fromCharCode(0x35) + NULLCHAR.repeat(5) },
  { key: ',', value: NULLCHAR.repeat(2) + String.fromCharCode(0x36) + NULLCHAR.repeat(5) },
  { key: '.', value: NULLCHAR.repeat(2) + String.fromCharCode(0x37) + NULLCHAR.repeat(5) },
  { key: '/', value: NULLCHAR.repeat(2) + String.fromCharCode(0x38) + NULLCHAR.repeat(5) },
  { key: '\\', value: NULLCHAR.repeat(2) + String.fromCharCode(0x64) + NULLCHAR.repeat(5) }, // Keyboard Non-US \
  
  // chars with shift
  { key: '_', value: LSHIFT + NULLCHAR + String.fromCharCode(0x2d) + NULLCHAR.repeat(5) },
  { key: '+', value: LSHIFT + NULLCHAR + String.fromCharCode(0x2e) + NULLCHAR.repeat(5) },
  { key: '{', value: LSHIFT + NULLCHAR + String.fromCharCode(0x2f) + NULLCHAR.repeat(5) },
  { key: '}', value: LSHIFT + NULLCHAR + String.fromCharCode(0x30) + NULLCHAR.repeat(5) },
  { key: '~', value: LSHIFT + NULLCHAR + String.fromCharCode(0x32) + NULLCHAR.repeat(5) }, // Keyboard Non-US ~
  { key: ':', value: LSHIFT + NULLCHAR + String.fromCharCode(0x33) + NULLCHAR.repeat(5) },
  { key: '@', value: LSHIFT + NULLCHAR + String.fromCharCode(0x34) + NULLCHAR.repeat(5) },
  { key: '<', value: LSHIFT + NULLCHAR + String.fromCharCode(0x36) + NULLCHAR.repeat(5) },
  { key: '>', value: LSHIFT + NULLCHAR + String.fromCharCode(0x37) + NULLCHAR.repeat(5) },
  { key: '?', value: LSHIFT + NULLCHAR + String.fromCharCode(0x38) + NULLCHAR.repeat(5) },
  { key: '|', value: LSHIFT + NULLCHAR + String.fromCharCode(0x64) + NULLCHAR.repeat(5) }, // Keyboard Non-US |
  
  // keys
  { key: 'RIGHT', value: NULLCHAR.repeat(2) + String.fromCharCode(0x4f) + NULLCHAR.repeat(5) },
  { key: 'LEFT', value: NULLCHAR.repeat(2) + String.fromCharCode(0x50) + NULLCHAR.repeat(5) },
  { key: 'DOWN', value: NULLCHAR.repeat(2) + String.fromCharCode(0x51) + NULLCHAR.repeat(5) },
  { key: 'UP', value: NULLCHAR.repeat(2) + String.fromCharCode(0x52) + NULLCHAR.repeat(5) },
  { key: 'DELETE', value: NULLCHAR.repeat(2) + String.fromCharCode(0x4c) + NULLCHAR.repeat(5) },
  { key: 'ENTER', value: NULLCHAR.repeat(2) + String.fromCharCode(0x28) + NULLCHAR.repeat(5) },
  { key: 'ESCAPE', value: NULLCHAR.repeat(2) + String.fromCharCode(0x29) + NULLCHAR.repeat(5) },
  { key: 'BACKSPACE', value: NULLCHAR.repeat(2) + String.fromCharCode(0x2a) + NULLCHAR.repeat(5) },
  { key: 'TAB', value: NULLCHAR.repeat(2) + String.fromCharCode(0x2b) + NULLCHAR.repeat(5) },
  { key: 'SPACE', value: NULLCHAR.repeat(2) + String.fromCharCode(0x2c) + NULLCHAR.repeat(5) },
  { key: 'CAD', value: CTRLALT + NULLCHAR + String.fromCharCode(0x4c) + NULLCHAR.repeat(5) },
  
  { key: 'RELEASE', value: NULLCHAR.repeat(8) }
];

const mapObject = {};
for (let i = 0; i < mapArray.length; i++) {
  const item = mapArray[i];
  mapObject[item.key] = item.value;
}

module.exports = {
  mapArray,
  mapObject
}
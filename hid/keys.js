const NULLCHAR = String.fromCharCode(0);
const LSHIFT = String.fromCharCode(0x02);

const map = {
  
  // lowercase
  'a': String.fromCharCode(0x04),
  'b': String.fromCharCode(0x05),
  'c': String.fromCharCode(0x06),
  'd': String.fromCharCode(0x07),
  'e': String.fromCharCode(0x08),
  'f': String.fromCharCode(0x09),
  'g': String.fromCharCode(0x0a),
  'h': String.fromCharCode(0x0b),
  'i': String.fromCharCode(0x0c),
  'j': String.fromCharCode(0x0d),
  'k': String.fromCharCode(0x0e),
  'l': String.fromCharCode(0x0f),
  'm': String.fromCharCode(0x10),
  'n': String.fromCharCode(0x11),
  'o': String.fromCharCode(0x12),
  'p': String.fromCharCode(0x13),
  'q': String.fromCharCode(0x14),
  'r': String.fromCharCode(0x15),
  's': String.fromCharCode(0x16),
  't': String.fromCharCode(0x17),
  'u': String.fromCharCode(0x18),
  'v': String.fromCharCode(0x19),
  'w': String.fromCharCode(0x1a),
  'x': String.fromCharCode(0x1b),
  'y': String.fromCharCode(0x1c),
  'z': String.fromCharCode(0x1d),
  
  // numbers
  '1': String.fromCharCode(0x1e),
  '2': String.fromCharCode(0x1f),
  '3': String.fromCharCode(0x20),
  '4': String.fromCharCode(0x21),
  '5': String.fromCharCode(0x22),
  '6': String.fromCharCode(0x23),
  '7': String.fromCharCode(0x24),
  '8': String.fromCharCode(0x25),
  '9': String.fromCharCode(0x26),
  '0': String.fromCharCode(0x27),
  
  // numbers with shift
  '!': LSHIFT + NULLCHAR + String.fromCharCode(0x1e),
  '"': LSHIFT + NULLCHAR + String.fromCharCode(0x1f),
  '£': LSHIFT + NULLCHAR + String.fromCharCode(0x20),
  '$': LSHIFT + NULLCHAR + String.fromCharCode(0x21),
  '%': LSHIFT + NULLCHAR + String.fromCharCode(0x22),
  '^': LSHIFT + NULLCHAR + String.fromCharCode(0x23),
  '&': LSHIFT + NULLCHAR + String.fromCharCode(0x24),
  '*': LSHIFT + NULLCHAR + String.fromCharCode(0x25),
  '(': LSHIFT + NULLCHAR + String.fromCharCode(0x26),
  ')': LSHIFT + NULLCHAR + String.fromCharCode(0x27),
  
  // chars
  '-': String.fromCharCode(0x2d),
  '=': String.fromCharCode(0x2e),
  '[': String.fromCharCode(0x2f),
  ']': String.fromCharCode(0x30),
  '#': String.fromCharCode(0x32), // Keyboard Non-US #
  ';': String.fromCharCode(0x33),
  '\'': String.fromCharCode(0x34),
  '`': String.fromCharCode(0x35),
  ',': String.fromCharCode(0x36),
  '.': String.fromCharCode(0x37),
  '/': String.fromCharCode(0x38),
  '\\': String.fromCharCode(0x64), // Keyboard Non-US \
  
  // chars with shift
  '_': LSHIFT + NULLCHAR + String.fromCharCode(0x2d),
  '+': LSHIFT + NULLCHAR + String.fromCharCode(0x2e),
  '{': LSHIFT + NULLCHAR + String.fromCharCode(0x2f),
  '}': LSHIFT + NULLCHAR + String.fromCharCode(0x30),
  '~': LSHIFT + NULLCHAR + String.fromCharCode(0x32), // Keyboard Non-US ~
  ':': LSHIFT + NULLCHAR + String.fromCharCode(0x33),
  '@': LSHIFT + NULLCHAR + String.fromCharCode(0x34),
  '<': LSHIFT + NULLCHAR + String.fromCharCode(0x36),
  '>': LSHIFT + NULLCHAR + String.fromCharCode(0x37),
  '?': LSHIFT + NULLCHAR + String.fromCharCode(0x38),
  '|': LSHIFT + NULLCHAR + String.fromCharCode(0x64), // Keyboard Non-US |
  
  // keys
  'right': String.fromCharCode(0x4f),
  'left': String.fromCharCode(0x50),
  'down': String.fromCharCode(0x51),
  'up': String.fromCharCode(0x52),
  'delete': String.fromCharCode(0x4c),
  'return': String.fromCharCode(0x28),
  'escape': String.fromCharCode(0x29),
  'backspace': String.fromCharCode(0x2a),
  'tab': String.fromCharCode(0x2b),
  'space': String.fromCharCode(0x2c),
  
  'release': NULLCHAR.repeat(8)
};

const getKeySequence = (keyName, ctrl, shift, alt) => {
  const mapSequence = map[keyName];
  if (!mapSequence) {
    // no mapping
    return null;
  }
  // skip symbols that have predefined prefixes
  if (mapSequence.length > 1) {
    return mapSequence + NULLCHAR.repeat(5);
  }
  let modifier = 0;
  if (ctrl) {
    modifier += 0x01; // left ctrl
  }
  if (shift) {
    modifier += 0x02; // left shift
  }
  if (alt) {
    modifier += 0x04; // left alt
  }
  if (modifier > 0) {
    return String.fromCharCode(modifier) + NULLCHAR + mapSequence + NULLCHAR.repeat(5);
  }
  return NULLCHAR.repeat(2) + mapSequence + NULLCHAR.repeat(5);
};

const getReleaseSequence = () => {
  return map['release'];
};

module.exports = {
  getKeySequence,
  getReleaseSequence
};

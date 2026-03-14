let lastCharging = null;
let lastPercentage = null;
let lastTimestamp = null;

let estimatedSeconds = null;
const rates = [];

const recordCharge = (percentage) => {
  if (typeof percentage !== 'number' || !Number.isInteger(percentage) || percentage < 1 || percentage > 100) return;
  const now = Date.now();
  if (lastPercentage === null) {
    lastPercentage = percentage;
    lastTimestamp = now;
    return;
  }
  if (percentage === lastPercentage) return;

  const nowCharging = percentage > lastPercentage;
  
  if (lastCharging !== null && nowCharging !== lastCharging) {
    lastCharging = nowCharging;
    lastPercentage = percentage;
    lastTimestamp = now;
    rates.length = 0;
    estimatedSeconds = null;
    return;
  }
  
  lastCharging = nowCharging;
  
  const elapsedSeconds = (now - lastTimestamp) / 1000;
  if (elapsedSeconds <= 0) return;

  const delta = percentage - lastPercentage;
  const rate = delta / elapsedSeconds;

  rates.push(rate);
  if (rates.length > 3) rates.shift();
  const avgRate = rates.reduce((a, b) => a + b, 0) / rates.length;

  estimatedSeconds = lastCharging
    ? (100 - percentage) / avgRate
    : percentage / -avgRate;

  lastPercentage = percentage;
  lastTimestamp = now;
};

const getRemaining = () => {
  if (estimatedSeconds === null) return null;
  const h = Math.floor(estimatedSeconds / 3600);
  const m = Math.floor((estimatedSeconds % 3600) / 60);
  const time = h > 0 ? `${h}h ${m}m` : `${m}m`;
  return lastCharging ? `${time}, charging` : `${time}, discharging`;
};

module.exports = {
  recordCharge,
  getRemaining
};

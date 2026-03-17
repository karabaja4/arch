let lastCharging = null;
let lastPercentage = null;
let lastTimestamp = null;

let estimatedMs = null;
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
  
  if (nowCharging !== lastCharging) {
    // reset everything on direction flip and start over
    lastCharging = nowCharging;
    lastPercentage = percentage;
    lastTimestamp = now;
    rates.length = 0;
    estimatedMs = null;
    return;
  }
  
  const elapsed = now - lastTimestamp;
  if (elapsed <= 0) return;

  const delta = percentage - lastPercentage;
  const rate = delta / elapsed;

  rates.push(rate);
  if (rates.length > 3) rates.shift();
  const avgRate = rates.reduce((a, b) => a + b, 0) / rates.length;

  estimatedMs = lastCharging
    ? (100 - percentage) / avgRate
    : percentage / -avgRate;

  lastPercentage = percentage;
  lastTimestamp = now;
};

const getRemaining = () => {
  if (estimatedMs === null) return null;
  if (lastPercentage === 100) return "charged";
  if (lastPercentage === 0) return "empty";
  const totalSeconds = estimatedMs / 1000;
  const h = Math.floor(totalSeconds / 3600);
  const m = Math.floor((totalSeconds % 3600) / 60);
  const time = h > 0 ? `${h}h ${m}m` : `${m}m`;
  return lastCharging ? `${time}, charging` : `${time}, discharging`;
};

module.exports = {
  recordCharge,
  getRemaining
};

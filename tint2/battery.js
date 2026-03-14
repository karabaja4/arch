let lastPercentage = null;
let lastTimestamp = null;
let estimatedSeconds = null;
let charging = null;
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

  const elapsedSeconds = (now - lastTimestamp) / 1000;
  if (elapsedSeconds <= 0) return;

  const delta = percentage - lastPercentage;
  const rate = delta / elapsedSeconds;

  const nowCharging = delta > 0;
  if (nowCharging !== charging) {
    charging = nowCharging;
    rates.length = 0;
  }

  rates.push(rate);
  if (rates.length > 3) rates.shift();
  const avgRate = rates.reduce((a, b) => a + b, 0) / rates.length;

  estimatedSeconds = charging
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
  return charging ? `${time}, charging` : `${time}, discharging`;
};

module.exports = {
  recordCharge,
  getRemaining
};

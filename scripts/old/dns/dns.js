const axios = require('axios');
const secret = require('../secret.json');

const log = (msg) => {
  console.log(`[${(new Date()).toISOString()}]: ${msg}`);
};

const request = async (method, uri, headers, data) => {
  const config = {
    method: method,
    url: uri
  }
  if (headers) {
    config.headers = headers;
  }
  if (data) {
    config.data = data;
  }
  return await axios.request(config);
}

const main = async () => {
  const headers = {
    Authorization: `Bearer ${secret.dns.token}`
  }
  try {
    const ip = await request('GET', 'https://api.ipify.org');
    const record = await request('GET', secret.dns.record, headers);
    if (ip.data !== record.data.domain_record.data) {
      await request('PUT', secret.dns.record, headers, { data: ip.data });
      log(`Updated to ${ip.data}`);
    } else {
      log('No update necessary.');
    }
  }
  catch (err) {
    log(err.message);
  }
}

main();
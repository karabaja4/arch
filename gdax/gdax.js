const Gdax = require('gdax');
const request = require('request');
const async = require('async');
const secret = require('./secret.json');
const fs = require('fs');

const apiURI = 'https://api.pro.coinbase.com';
const publicClient = new Gdax.PublicClient();

const eurId = "cb130c23-1daa-475d-a679-2a5900d28b24";
const btcId = "a3593b1c-08b7-4f53-8ab8-d3ab666ad037";

// cached date
let hnbDate = null;
let hnbValue = null;
Date.prototype.addHours = function(h) {
    var date = new Date(this.getTime());
    date.setHours(date.getHours() + h);
    return date;
}

const authedClient = new Gdax.AuthenticatedClient(
    secret.gdaxKey,
    secret.gdaxSecret,
    secret.gdaxPassphrase,
    apiURI
);

const hnb = (callback) => {
    const now = new Date();
    const shouldFetch = !hnbDate || !hnbValue || (now > hnbDate.addHours(6));
    if (shouldFetch) {
        request('http://api.hnb.hr/tecajn/v1?valuta=EUR', { json: true }, (err, res, body) => {
            const value = body && parseFloat(body[0]["Kupovni za devize"].replace(",", "."));
            if (!err && value) {
                hnbDate = new Date();
                hnbValue = value;
            }
            callback(err, value);
        });
    }
    else {
        callback(null, hnbValue);
    }
};

const price = (callback) => {
    publicClient.getProductTicker('BTC-EUR', (err, response, data) => {
        callback(err, data && parseFloat(data.price));
    });
}

const account = (id, callback) => {
    authedClient.getAccount(id, (err, response, data) => {
        callback(err, data && parseFloat(data.balance));
    });
}

const eur = (callback) => account(eurId, callback);
const btc = (callback) => account(btcId, callback);

const print = (text1, text2, text3) => {
    const separator = `<span foreground="#FFFFFF">  |  </span>`;
    const first = `<span foreground="#90EE90">${text1 || "-"}</span>`;
    const second = `<span foreground="#FFB6C1">${text2 || "-"}</span>`;
    const third = `<span foreground="#87CEFA">${text3 || "-"}</span>`;
    const content = first + separator + second + separator + third;
    console.log(content);
    fs.writeFile("/tmp/gdax", content, (err) => {});
}

var exec = () => {
    async.parallel([hnb, price, btc, eur], (err, results) => {
        const btcAmount = results[0] * results[1] * results[2];
        const eurAmount = results[3];
        const btcPrice = results[1];
        const format = (amount, currency) => {
            return (amount || (amount === 0)) ? (amount.toFixed(2) + " " + currency) : null;
        }
        print(format(eurAmount, "EUR"), format(btcPrice, "EUR"), format(btcAmount, "BTC (HRK)"));
    });
}

setInterval(exec, 10000);
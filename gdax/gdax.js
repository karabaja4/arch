const gdax = require('gdax');
const request = require('request');
const async = require('async');
const secret = require('./secret.json');
const fs = require('fs');

const api = 'https://api.pro.coinbase.com';
const public = new gdax.PublicClient();

const eurId = "cb130c23-1daa-475d-a679-2a5900d28b24";
const btcId = "a3593b1c-08b7-4f53-8ab8-d3ab666ad037";

// cached date
let hnbDate = null;
let hnbValue = null;
Date.prototype.addHours = function(hours) {
    var date = new Date(this.getTime());
    date.setHours(date.getHours() + hours);
    return date;
}

const auth = new gdax.AuthenticatedClient(
    secret.gdaxKey,
    secret.gdaxSecret,
    secret.gdaxPassphrase,
    api
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
            console.log("Updated HNB exchange rate to " + value)
            callback(err, value);
        });
    }
    else {
        callback(null, hnbValue);
    }
};

const price = (callback) => {
    public.getProductTicker('BTC-EUR', (err, response, data) => {
        callback(err, data && parseFloat(data.price));
    });
}

const account = (id, callback) => {
    auth.getAccount(id, (err, response, data) => {
        callback(err, data && parseFloat(data.balance));
    });
}

const eur = (callback) => account(eurId, callback);
const btc = (callback) => account(btcId, callback);

const print = (texts) => {
    let content = "";
    for (let i = 0; i < texts.length; i++) {
        const text = texts[i].text;
        const color = texts[i].color;
        content += `<span foreground="${color}">${text || "-"}</span>`;
        if (i < (texts.length - 1)) {
            content += `<span foreground="#FFFFFF">  |  </span>`;
        }
    }
    console.log(content);
    fs.writeFile("/tmp/gdax", content, (err) => {});
}

var exec = () => {
    async.parallel([hnb, price, btc, eur], (err, results) => {
        if (err) {
            console.log(err);
        }
        const btcAmountHrk = results[0] * results[1] * results[2];
        const btcAmountEur = results[1] * results[2];
        const eurAmount = results[3];
        const btcPrice = results[1];
        const format = (amount, currency) => {
            return (amount || (amount === 0)) ? (amount.toFixed(2) + " " + currency) : null;
        }
        const texts = [
            { text: format(eurAmount, "EUR"), color: "#87CEFA" },
            { text: format(btcPrice, "EUR"), color: "#FFB6C1" },
            { text: format(btcAmountEur, "BTC (EUR)"), color: "#90EE90" }
        ];
        print(texts);
    });
}

setInterval(exec, 10000);
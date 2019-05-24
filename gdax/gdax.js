const gdax = require('gdax');
const request = require('request');
const async = require('async');
const secret = require('./secret.json');
const fs = require('fs');

const api = 'https://api.pro.coinbase.com';
const public = new gdax.PublicClient();
const auth = new gdax.AuthenticatedClient(
    secret.gdaxKey,
    secret.gdaxSecret,
    secret.gdaxPassphrase,
    api
);

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

const hnb = (currency, callback) => {
    const now = new Date();
    const shouldFetch = !hnbDate || !hnbValue || (now > hnbDate.addHours(6));
    if (shouldFetch) {
        request("http://api.hnb.hr/tecajn/v1?valuta=" + currency, { json: true }, (err, res, body) => {
            const value = body && parseFloat(body[0]["Kupovni za devize"].replace(",", "."));
            if (!err && value) {
                hnbDate = new Date();
                hnbValue = value;
                console.log("Updated HNB exchange rate to " + value);
            }
            callback(err, value);
        });
    }
    else {
        callback(null, hnbValue);
    }
};

const price = (pair, callback) => {
    public.getProductTicker(pair, (err, response, data) => {
        callback(err, data && parseFloat(data.price));
    });
}

const account = (id, callback) => {
    auth.getAccount(id, (err, response, data) => {
        callback(err, data && parseFloat(data.balance));
    });
}

let lastBtcPriceUsd = null;
let lastBtcPriceDiff = null;

const initialCost = 15473.03;

const exec = () => {
    const tasks = [
        (callback) => hnb("EUR", callback),
        (callback) => price("BTC-EUR", callback),
        (callback) => price("BTC-USD", callback),
        (callback) => account(btcId, callback),
        (callback) => account(eurId, callback)
    ];

    async.parallel(tasks, (err, results) => {

        let trend = "#757575"; // gray
        let conky = "-";

        if (!err) {
            const eurToHrkValue = results[0];
            const btcPriceInEur = results[1];
            const btcPriceInUsd = results[2];
            const btcAmount = results[3];
            const eurAmount = results[4];
    
            const btcAmountHrk = eurToHrkValue * btcPriceInEur * btcAmount;
            const eurAmountHrk = eurToHrkValue * eurAmount;
            //const btcAmountEur = btcPriceInEur * btcAmount;
            //const btcAmountUsd = btcPriceInUsd * btcAmount;
    
            const gainsDiff = ((btcAmountHrk > 1) ? btcAmountHrk : eurAmountHrk) - initialCost;
            let priceDiff = lastBtcPriceUsd !== null ? (btcPriceInUsd - lastBtcPriceUsd) : 0;
    
            lastBtcPriceUsd = btcPriceInUsd;
            priceDiff = priceDiff || lastBtcPriceDiff || 0;
            lastBtcPriceDiff = priceDiff;
    
            const format = (amount, currency, showPlus) => {
                return (amount || (amount === 0)) ? ((showPlus && (amount > 0) ? "+" : "") + amount.toFixed(2) + currency) : null;
            }
    
            trend = priceDiff === 0 ? "#EEFF41" : (priceDiff > 0 ? "#69F0AE" : "#FF6E40");
            conky = format(btcPriceInUsd, " USD") + " | " + format(priceDiff, "", true) + " | " + format(gainsDiff, " HRK", true);
        }

        console.log(trend + ": " + conky);
        if (err) {
            console.log(err);
        }
        fs.writeFile("/tmp/btctrend", trend, () => {});
        fs.writeFile("/tmp/btcconky", conky, () => {});
        setTimeout(() => exec(), 2000);
    });
}

exec();
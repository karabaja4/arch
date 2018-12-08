const gdax = require('gdax');
const request = require('request');
const async = require('async');
const secret = require('./secret.json');
const fs = require('fs');
const execute = require('child_process').exec;

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

const battery = (callback) => {
    execute('acpi', (error, stdout, stderr) => {
        if (error) {
            callback(error);
        } else {
            const split = stdout.trim().split(",");
            const percent = parseInt(split[1].trim().replace("%", ""));
            const time = split[2].trim().split(" ")[0];
            callback(null, {
                percent: percent,
                time: time
            });
        }
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

const getColor = (percent) => {
    if (percent >= 66) {
        return "#90EE90";
    } else if (percent >= 33) {
        return "#F0E68C";
    } else {
        return "#F0E68C";
    }
}

const exec = () => {
    async.parallel([hnb, price, btc, eur, battery], (err, results) => {
        if (err) {
            console.log(err);
        }
        //const kunaEurValue = results[0];
        const btcPrice = results[1];
        const btcAmount = results[2];
        const eurAmount = results[3];
        const batteryData = results[4];

        //const btcAmountHrk = kunaEurValue * btcPrice * btcAmount;
        //const btcAmountEur = btcPrice * btcAmount;
        
        const format = (amount, currency) => {
            return (amount || (amount === 0)) ? (amount.toFixed(2) + " " + currency) : null;
        }
        const texts = [];

        texts.push({ text: format(btcPrice, "(P)"), color: "#87CEFA" });

        if (eurAmount > 0) {
            texts.push({ text: format(eurAmount, "(F)"), color: "#90EE90" });
        }
        if (btcAmount > 0) {
            texts.push({ text: format(btcAmount, "BTC"), color: "#FFB6C1" });
        }

        if (batteryData) {
            texts.push({
                text: batteryData.percent + "%" + " (" + batteryData.time + ")",
                color: getColor(batteryData.percent)
            });
        }

        print(texts);
        setTimeout(() => exec(), 2000);
    });
}

exec();
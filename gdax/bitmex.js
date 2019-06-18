const request = require('request');
const fs = require('fs');

const bitmex = (callback) =>
{
    const url = "https://www.bitmex.com/api/v1/trade?symbol=XBT&count=1&reverse=true";
    request(url, { json: true }, (err, res, body) =>
    {
        callback(err, body[0]["price"]);
    });
}

const yellow = "#EEFF41";
const green = "#69F0AE";
const red = "#FF6E40";
const minutes = 10;

let prices = [];

const exec = () =>
{
    bitmex((err, price) =>
    {
        if (err)
        {
            console.log(err);
        }
        else
        {
            const now = (new Date()).getTime();
            const last = prices.slice(-1).pop();
            const minute = 60 * 1000; // 1 minute in ms
            
            if (!last || ((last.time + minute) < now))
            {
                const elem =
                {
                    time: now,
                    price: price
                };
                prices.push(elem);
                //console.log("added price " + JSON.stringify(elem));
            }

            const previous = prices.slice(-(minutes + 1))[0]; // 10 od kraja, ili ako ih nema 10, prvi

            if (price > previous.price)
            {
                color = green;
            }
            else if (price < previous.price)
            {
                color = red;
            }
            else
            {
                color = yellow;
            }

            const percentage = ((price - previous.price) / previous.price) * 100;
            const increase = (percentage > 0 ? "+" : "") + percentage.toFixed(2);
            
            conky = `${price} USD | ${increase}% in last ${minutes} minutes`;

            fs.writeFile("/tmp/btctrend", color, () => {});
            fs.writeFile("/tmp/btcconky", conky, () => {});
            setTimeout(() => exec(), 2000);
        }
    });
}

exec();
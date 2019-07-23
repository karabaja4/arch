const fs = require('fs');
const WebSocket = require("ws");

//const yellow = "#EEFF41";
const green = "#69F0AE";
const red = "#FF6E40";
//const gray = "#757575";

const connect = () =>
{
    const ws = new WebSocket("wss://www.bitmex.com/realtime");
    ws.on("open", () =>
    {
        const instrument = JSON.stringify({ op: "subscribe", args: "instrument:XBTUSD" });
        ws.send(instrument);
    });
    
    ws.on("message", (data) =>
    {
        const parsed = JSON.parse(data);
        if (parsed.table == "instrument" && parsed.action == "update")
        {
            const info = parsed.data[0];
            if (info && info.lastPrice)
            {
                const direction = info.lastTickDirection == "ZeroPlusTick" || info.lastTickDirection == "PlusTick" ? 1 : -1;
                const color = direction == 1 ? green : red;
                const price = parseInt(info.lastPrice);
                const text = `${price} USD`;
                console.log(text);
                fs.writeFile("/tmp/btctrend", color, () => {});
                fs.writeFile("/tmp/btcconky", text, () => {});
            }
        }
    });
    
    // Close always gets called after error. This will call connect twice on an error.
    // ws.on('error', () =>
    // {
    //     console.log('socket error');
    // });

    ws.on("close", () =>
    {
        console.log("closed, reconnecting...");
        setTimeout(connect, 1000);
    });
};

connect();
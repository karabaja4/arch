const coinbase = require('coinbase');
const secret = require('./secret.json')
const client   = new coinbase.Client({'apiKey': secret.apiKey, 'apiSecret': secret.apiSecret});
const { exec } = require('child_process');
const async = require('async');

let pbz = false;

const print = (text1, text2) => {
	console.log(`<span foreground="aqua">${text1 || "-"}</span><span foreground="white">  |  </span><span foreground="lime">${text2 || "-"}</span>`);
}

const coinbaseGet = (callback) => {
    client.getAccount('a954c724-975b-54d1-824c-aa2e6dffe766', (err, account) => {
		try {
			callback(null, !err && account != null ? (account.native_balance.amount + " " + account.native_balance.currency) : null);
		} catch (e) {
			callback(null, null);
		}
    });
};

const pbzGet = (callback) => {
	if (pbz) {
		exec("curl -s -f " + secret.pbzCurl.slice(5), (error, stdout, stderr) => {
			try {
				const data = JSON.parse(stdout);
				const balance = data.jsonResponse.result.homePageCommandList[0].data.tableData[0].bankAccounts[0].balance.amount;
				const currency = data.jsonResponse.result.homePageCommandList[0].data.tableData[0].bankAccounts[0].accountCurrencyCode;
				callback(null, balance + " " + currency);
			} catch (e) {
				callback(null, null);
				pbz = false;
			}
		});
	} else {
		callback(null, null);
	}
}

async.parallel([coinbaseGet, pbzGet], (err, results) => {
	print(results[0], results[1]);
});

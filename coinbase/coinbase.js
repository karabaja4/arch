var coinbase = require('coinbase');
var secret = require('./secret.json')
var client   = new coinbase.Client({'apiKey': secret.apiKey, 'apiSecret': secret.apiSecret});

const print = (text) =>
{
	console.log('<span foreground="aqua">' + text + '</span>');
}

const get = () =>
{
    client.getAccount('a954c724-975b-54d1-824c-aa2e6dffe766', (err, account) =>
    {
		if (!err && account != null)
		{
			print(account.native_balance.amount + ' ' + account.native_balance.currency);
		}
    });
};

get();
//setInterval(() => {
//    get();
//}, 30000);


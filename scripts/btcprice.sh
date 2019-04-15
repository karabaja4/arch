#!/bin/bash

red="#FF6E40"
yellow="#EEFF41"
green="#69F0AE"

trendfile="/tmp/btctrend"
pricefile="/tmp/btcprice"
conkyfile="/tmp/btcconky"

rm $trendfile
rm $pricefile
rm $conkyfile

while true
do
	price=$(curl -s https://api.coinbase.com/v2/prices/BTC-USD/spot | jq -r '.data .amount' | xargs printf '%0.2f')
	oldprice="0.00"
	delta="0.00"

	if [ -f $pricefile ]; then
		oldprice="$(cat $pricefile)"
		delta=$(echo "$price - $oldprice" | bc | xargs printf '%0.2f')
	fi

	echo "New price is $price"
	echo "Old price is $oldprice"

	if [ 1 -eq "$(echo "${price} > ${oldprice}" | bc)" ]; then
		echo "Trend is up ($delta)"
		echo -n $green > $trendfile
		echo -n $price > $pricefile
		echo -n "$price USD (+$delta)" > $conkyfile
	elif [ 1 -eq "$(echo "${price} < ${oldprice}" | bc)" ]; then
		echo "Trend is down ($delta)"
		echo -n $red > $trendfile
		echo -n $price > $pricefile
		echo -n "$price USD ($delta)" > $conkyfile
	else
		echo "Trend is neutral ($delta)"
		echo -n $yellow > $trendfile
		echo -n $price > $pricefile
		echo -n "$price USD ($delta)" > $conkyfile
	fi
    
	sleep 30
done
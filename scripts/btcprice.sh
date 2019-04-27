#!/bin/bash

red="#FF6E40"
yellow="#EEFF41"
green="#69F0AE"
gray="#757575"

trendfile="/tmp/btctrend"
pricefile="/tmp/btcprice"
conkyfile="/tmp/btcconky"

rm -f $trendfile
rm -f $pricefile
rm -f $conkyfile

while true
do
	result=$(curl -s https://api.coinbase.com/v2/prices/BTC-USD/spot)
	if [ $? == 0 ]; then

		price=$(echo $result | jq -r '.data .amount' | xargs printf '%0.2f')
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
			echo -n "$price USD | +$delta" > $conkyfile
		elif [ 1 -eq "$(echo "${price} < ${oldprice}" | bc)" ]; then
			echo "Trend is down ($delta)"
			echo -n $red > $trendfile
			echo -n $price > $pricefile
			echo -n "$price USD | $delta" > $conkyfile
		else
			echo "Trend is neutral ($delta)"
			echo -n $yellow > $trendfile
			echo -n $price > $pricefile
			echo -n "$price USD | $delta" > $conkyfile
		fi

	else
		echo "Price not available"
		echo -n $gray > $trendfile
		echo -n "N/A" > $conkyfile
	fi
    
	sleep 30
done
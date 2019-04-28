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
	if [[ $? == 0 ]]
	then

		price=$(echo $result | jq -r '.data .amount' | xargs printf '%0.2f')
		oldprice="0.00"
		delta="0.00"

		if [[ -f $pricefile ]]
		then
			oldprice="$(cat $pricefile)"
			delta=$(echo "$price - $oldprice" | bc | xargs printf '%0.2f')
		fi

		if [[ 1 -eq "$(echo "${price} > ${oldprice}" | bc)" ]] && [[ "$delta" != "0.00" ]]; then
			echo -n $green > $trendfile
		elif [[ 1 -eq "$(echo "${price} < ${oldprice}" | bc)" ]]; then
			echo -n $red > $trendfile
		else
			echo -n $yellow > $trendfile
		fi

		# add + to positive deltas
		if [[ "$delta" != "0.00" ]] && [[ "${delta:0:1}" != "-" ]]
		then
			delta="+$delta"
		fi

		echo -n $price > $pricefile
		
		out="$price USD | $delta"
		echo $out
		echo -n $out > $conkyfile

	else
		echo "Price not available"
		echo -n $gray > $trendfile
		echo -n "N/A" > $conkyfile
	fi
    
	sleep 30
done
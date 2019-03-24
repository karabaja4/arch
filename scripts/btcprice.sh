#!/bin/bash

while true
do
	price=$(curl -s https://api.coinbase.com/v2/prices/BTC-USD/spot | jq -r '.data .amount')
    printf "%0.2f" $price > /tmp/btcprice
	sleep 30
done
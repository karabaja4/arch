#!/bin/bash

while true
do
	echo ""
	wget -q -O- "http://freedns.afraid.org/dynamic/update.php?token"
	echo "updated on $(date)"

	sleep 180
done

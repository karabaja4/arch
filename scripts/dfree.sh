#!/bin/sh

if [ -b /dev/sdc1 ]
then
	df /dev/sdc1 | tail -1 | awk '{print $3+$4" "$4}'
else
	echo 0 0
fi

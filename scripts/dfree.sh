#!/bin/sh

if [ -b /dev/sdb1 ]
then
	df /dev/sdb1 | tail -1 | awk '{print $3+$4" "$4}'
else
	echo 0 0
fi

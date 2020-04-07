#!/bin/bash

declare monitor1="HDMI-1-1"
declare monitor2="DP-1-1"
declare width=1280
declare height=800
declare refresh=60

xrandr --newmode $(cvt ${width} ${height} ${refresh} | grep Modeline | sed -e 's/^Modeline //' | sed -e 's/\"//g')

xrandr --addmode ${monitor1} ${width}x${height}_${refresh}.00
xrandr --addmode ${monitor2} ${width}x${height}_${refresh}.00

xrandr --output ${monitor1} --mode ${width}x${height}_${refresh}.00 --primary
xrandr --output ${monitor2} --mode ${width}x${height}_${refresh}.00 --right-of ${monitor1}
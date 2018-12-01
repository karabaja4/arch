#!/bin/bash

declare monitor="HDMI-1-1"
declare width=1280
declare height=800
declare refresh=60

xrandr --newmode $(cvt ${width} ${height} ${refresh} | grep Modeline | sed -e 's/^Modeline //' | sed -e 's/\"//g')
xrandr --addmode ${monitor} ${width}x${height}_${refresh}.00
xrandr --output ${monitor} --mode ${width}x${height}_${refresh}.00 --primary
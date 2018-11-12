#!/bin/bash

function addmode() {
    echo "Adding mode: $1 $2"
    xrandr --newmode $(cvt $1 $2 60 |grep Modeline | sed -e 's/^Modeline //' | sed -e 's/\"//g')
    xrandr --addmode HDMI-1-1 $1x$2_60.00
}

addmode 1280 800
xrandr --output HDMI-1-1 --mode 1280x800_60.00 --primary
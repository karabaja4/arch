#!/bin/sh
set -eu

if ! grep -q "RUNNING" /proc/asound/card*/pcm*/sub*/status
then
    if [ "$(DISPLAY=:0 xprintidle)" -gt 300000 ] # 5 min = 300000 ms
    then
        xset -display :0.0 dpms force off
    fi
fi

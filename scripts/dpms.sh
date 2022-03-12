#!/bin/sh
set -eu

xset -display :1 dpms 0 0 0

if ! grep -q "RUNNING" /proc/asound/card*/pcm*/sub*/status
then
    if [ "$(DISPLAY=:1 xprintidle)" -gt 300000 ] # 5 min = 300000 ms
    then
        xset -display :1 dpms force off
    fi
fi

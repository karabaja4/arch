#!/bin/sh
set -eu

export XAUTHORITY="${HOME}/.local/share/sx/xauthority"
export DISPLAY=":1"

xset dpms 0 0 0

if ! grep -q "RUNNING" /proc/asound/card*/pcm*/sub*/status
then
    if [ "$(xprintidle)" -gt 300000 ] # 5 min = 300000 ms
    then
        xset dpms force off
    fi
fi

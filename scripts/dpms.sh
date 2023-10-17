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
        exit 0
    fi
fi

# if we didn't exit, means computer is used
# ping disk to prevent spindown
_mp="${HOME}/_disk"
if mountpoint -q "${_mp}"
then
    printf '%s\n' "$(date -Is)" > "${_mp}/ping"
fi
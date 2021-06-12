#!/bin/sh
set -eu

_shot() (
    _idx=1
    xrandr | grep -o '[0-9]*x[0-9]*[+-][0-9]*[+-][0-9]*' | while read -r res
    do
        echo "Screenshoting: ${res} (${_idx})"
        maim -u -g "${res}" > "/tmp/screenshots/$(date +%s%N)_${_idx}.png"
        _idx=$(( _idx + 1 ))
    done
)

mkdir -p /tmp/screenshots/
_shot
#!/bin/sh
set -eu

_shot() {
    _idx=1
    for _res in $(xrandr | grep -o '[0-9]*x[0-9]*[+-][0-9]*[+-][0-9]*')
    do
        printf 'Screenshoting: %s (%s)\n' "${_res}" "${_idx}"
        maim -u -g "${_res}" > "/tmp/screenshots/$(date +%s%N)_${_idx}.png"
        _idx=$(( _idx + 1 ))
    done
}

mkdir -p /tmp/screenshots/
_shot
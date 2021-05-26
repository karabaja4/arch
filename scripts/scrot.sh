#!/bin/bash
set -euo pipefail

_shot() {
    local -a _resolutions=()
    mapfile -t _resolutions < <(xrandr | grep -o '[0-9]*x[0-9]*[+-][0-9]*[+-][0-9]*')
    local -i idx=1
    for res in "${_resolutions[@]}"
    do
        echo "Screenshoting: ${res} (${idx})"
        maim -u -g "${res}" > "/tmp/screenshots/$(date +%s%N)_${idx}.png"
        (( idx++ ))
    done
}

mkdir -p /tmp/screenshots/
_shot
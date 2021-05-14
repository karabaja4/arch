#!/bin/bash
# shellcheck disable=SC2155
set -euo pipefail

declare -r _current="$(xset -display :0.0 q | awk '/DPMS is/ { print $3 }')"

_enable() {
    if [[ "${_current}" == "Disabled" ]]
    then
        xset -display :0.0 +dpms
    fi
}

_disable() {
    if [[ "${_current}" == "Enabled" ]]
    then
        xset -display :0.0 -dpms
    fi
}

if grep -q "RUNNING" /proc/asound/card*/pcm*/sub*/status
then
    _disable
else
    _enable
fi

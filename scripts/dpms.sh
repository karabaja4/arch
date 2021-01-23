#!/bin/bash
# shellcheck disable=SC2155
set -euo pipefail

declare -ir _timeout=600
declare -ir _current="$(xset -display :0.0 q | awk '/Standby:/ { print $2 }')"

_enable() {
    if [[ "${_current}" == "0" ]]
    then
        xset -display :0.0 dpms ${_timeout} ${_timeout} ${_timeout}
    fi
}

_disable() {
    if [[ "${_current}" != "0" ]]
    then
        xset -display :0.0 dpms 0 0 0
    fi
}

if grep -q "RUNNING" /proc/asound/card*/pcm*/sub*/status
then
    _disable
else
    _enable
fi

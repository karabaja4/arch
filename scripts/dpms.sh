#!/bin/bash
# shellcheck disable=SC2155

declare -r timeout=600
declare -r current="$(xset q | awk '/Standby:/ { print $2 }')"

_enable() {
    if [[ "${current}" == "0" ]]
    then
        xset -display :0.0 dpms ${timeout} ${timeout} ${timeout}
    fi
}

_disable() {
    if [[ "${current}" == "${timeout}" ]]
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

#!/bin/sh
set -eu

_echo() {
    printf '%s\n' "${1}"
}

_echo "$(basename "${0}") @ $(readlink /proc/$$/exe)"
_current="$(xset -display :0.0 q | awk '/DPMS is/ { print $3 }')"
_echo "DPMS: ${_current}"

_enable() {
    if [ "${_current}" = "Disabled" ]
    then
        xset -display :0.0 +dpms
        _echo "DPMS: ${_current} -> Enabled"
    fi
}

_disable() {
    if [ "${_current}" = "Enabled" ]
    then
        xset -display :0.0 -dpms
        _echo "DPMS: ${_current} -> Disabled"
    fi
}

if grep -q "RUNNING" /proc/asound/card*/pcm*/sub*/status
then
    _echo "ALSA: Running"
    _disable
else
    _echo "ALSA: Stopped"
    _enable
fi

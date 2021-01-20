#!/bin/bash

set -uo pipefail

_usage() {
    echo "usage: ${0} [speakers | headphones [headset] | maxvolume]"
    exit 1
}

(( ${#} == 0 )) && _usage

_unmute_max_all() {
    amixer set Master unmute &> /dev/null
    amixer set Master 100% &> /dev/null
    amixer set Headphone unmute &> /dev/null
    amixer set Headphone 100% &> /dev/null
    amixer set Mic unmute &> /dev/null
    amixer set Mic 100% &> /dev/null
}

_max_volume() {
    _unmute_max_all
    echo "Set volume to 100%"
}

_write_asoundrc() {
    echo -e "defaults.ctl.card ${1}\ndefaults.pcm.card ${1}\ndefaults.pcm.device 0" > "${HOME}/.asoundrc"
}

_switch_card() {
    local -r id="$(grep "${1}" /proc/asound/cards | awk '{print $1; exit;}')"
    if [[ -z ${id} ]]
    then
        echo "Card ${1} not found, exiting"
        exit 1
    fi
    _write_asoundrc "${id}"
    echo "Switched to card ${id} (${1})"
}

case "${1}" in
speakers)
    _switch_card PCH
    ;;&
headphones|headset)
    _switch_card Headset
    ;;&
speakers|headphones|headset|maxvolume)
    _max_volume
    ;;
*)
    _usage
    ;;
esac

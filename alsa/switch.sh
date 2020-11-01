#!/bin/bash
set -uo pipefail

usage() {
    echo "usage: switch.sh [speakers | headphones [headset] | maxvolume]"
    exit 1
}

[ ${#} -eq 0 ] && usage

set_max_amixer() {
    amixer set Master unmute &> /dev/null
    amixer set Master 100% &> /dev/null
    amixer set Headphone unmute &> /dev/null
    amixer set Headphone 100% &> /dev/null
    amixer set Mic unmute &> /dev/null
    amixer set Mic 100% &> /dev/null
}

max_amixer() {
    set_max_amixer
    echo "Set volume to 100%"
}

write_asoundrc() {
    echo -e "defaults.ctl.card ${1}\ndefaults.pcm.card ${1}\ndefaults.pcm.device 0" > "${HOME}/.asoundrc"
}

switch_card() {
    declare -r id="$(grep "${1}" /proc/asound/cards | awk '{print $1; exit;}')"
    if [ -z "${id}" ]
    then
        echo "Card ${1} not found, exiting"
        exit 1
    fi
    write_asoundrc "${id}"
    echo "Switched to card ${id} (${1})"
}

case "${1}" in
speakers)
    switch_card PCH
    ;;&
headphones|headset)
    switch_card Headset
    ;;&
speakers|headphones|headset|maxvolume)
    max_amixer
    ;;
*)
    usage
    ;;
esac

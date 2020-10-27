#!/bin/bash
set -euo pipefail

usage() {
    echo "usage: switch.sh [speakers|headphones[headset]|maxvolume]"
    exit 1
}

[ ${#} -eq 0 ] && usage

execute_max_amixer() {
    amixer set Master unmute
    amixer set Master 100%
    amixer set Headphone unmute
    amixer set Headphone 100%
    amixer set Mic unmute
    amixer set Mic 100%
}

max_amixer() {
    execute_max_amixer &> /dev/null || true
    echo "Set volume to 100%"
}

write_asoundrc() {
    echo -e "defaults.ctl.card ${1}\ndefaults.pcm.card ${1}\ndefaults.pcm.device 0" > "${HOME}/.asoundrc"
}

switch_card() {
    declare -r number="$(awk -v pattern="${1}" '$0 ~ pattern {print $1; exit;}' /proc/asound/cards)"
    write_asoundrc "${number}"
    echo "Switched to card ${number} (${1})"
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

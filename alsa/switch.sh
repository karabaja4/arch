#!/bin/bash
set -euo pipefail

usage() {
    echo "usage: switch.sh [speakers|headphones[headset]|maxvolume]"
    exit 1
}

[ ${#} -eq 0 ] && usage

max_amixer() {
    amixer set Master unmute &> /dev/null || true
    amixer set Master 100% &> /dev/null || true
    amixer set Headphone unmute &> /dev/null || true
    amixer set Headphone 100% &> /dev/null || true
    amixer set Mic unmute &> /dev/null || true
    amixer set Mic 100% &> /dev/null || true
    echo "Set amixer volume to 100%"
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

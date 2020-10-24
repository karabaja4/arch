#!/bin/bash
set -euo pipefail

usage() {
    echo "usage: switch.sh [speakers|headphones|master]"
    exit 1
}

[ ${#} -eq 0 ] && usage

asoundrc() {
    echo -e "defaults.ctl.card ${1}\ndefaults.pcm.card ${1}\ndefaults.pcm.device 0" > "${HOME}/.asoundrc"
}

case "${1}" in
speakers)
    asoundrc "$(awk '/PCH/{print $1; exit;}' /proc/asound/cards)"
    amixer set Master unmute > /dev/null
    amixer set Master 100% > /dev/null
    ;;
headphones)
    asoundrc "$(awk '/Headset/{print $1; exit;}' /proc/asound/cards)"
    amixer set Headphone unmute > /dev/null
    amixer set Headphone 100% > /dev/null
    amixer set Mic unmute > /dev/null
    amixer set Mic 100% > /dev/null
    ;;
master)
    amixer set Master unmute > /dev/null
    amixer set Master 100% > /dev/null
    ;;
*)
    usage
    ;;
esac

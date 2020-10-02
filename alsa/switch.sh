#!/bin/bash
set -euo pipefail

usage() {
    echo "usage: switch.sh [speakers|headset|master]"
    exit 1
}

[ ${#} -eq 0 ] && usage

declare -r basedir="$(dirname "$(readlink -f "${0}")")"

case "${1}" in
speakers)
    ln -sf "${basedir}/asoundrc.speakers" "${HOME}/.asoundrc"
    amixer set Master unmute > /dev/null
    amixer set Master 100% > /dev/null
    ;;
headset)
    ln -sf "${basedir}/asoundrc.headset" "${HOME}/.asoundrc"
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

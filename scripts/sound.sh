#!/bin/bash
set -uo pipefail

_usage() {
    echo "usage: ${0} [speakers | headphones [headset] | maxvolume]"
    exit 1
}

(( ${#} == 0 )) && _usage

_unmute_max_all() {
    for channel in $(amixer | grep -B1 -E "Capabilities:.*pvolume" | grep -oP "(?<=Simple mixer control ').+(?=')")
    do
        echo "Unmuting ${channel} to 100%"
        amixer set "${channel}" unmute &> /dev/null
        amixer set "${channel}" 100% &> /dev/null
    done
}

_write_asoundrc() {
    echo -e "defaults.ctl.card ${1}\ndefaults.pcm.card ${1}" > "${HOME}/.asoundrc"
}

_switch_card() {
    local -r id="$(grep -iH "${1}" /proc/asound/card*/id | grep -oP '(?<=/proc/asound/card)[0-9]+(?=/id)')"
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
    _unmute_max_all
    ;;
*)
    _usage
    ;;
esac

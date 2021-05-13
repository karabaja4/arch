#!/bin/bash
set -uo pipefail

_usage() {
    echo "usage: ${0} [ <card_name> | list ]"
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
    local -r search="$(grep -iwH "${1}" /proc/asound/card*/id)"
    if [[ -z ${search} ]]
    then
        echo "Card ${1} not found, exiting."
        exit 1
    fi
    local -r index="$(echo "${search%:*}" | grep -oP '(?<=/proc/asound/card)[0-9]+(?=/id)')"
    _write_asoundrc "${index}"
    echo "Switched to card ${search##*:} (${index})"
}

_list() {
    cat /proc/asound/card*/id
    exit 1
}

case "${1}" in
list)
    _list
    ;;
*)
    _switch_card "${1}"
    _unmute_max_all
    ;;
esac

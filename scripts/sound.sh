#!/bin/sh
set -u

_echo() {
    printf '%s\n' "${1}"
}

_usage() {
    _echo "usage: $(basename "${0}") [ <card_name> | l(ist) ]"
    exit 1
}

[ "${#}" -ne 1 ] && _usage

_unmute_max_all() {
    for channel in $(amixer | grep -P -B1 "^.*Capabilities:.* pvolume( .*$|$)" | grep -oP "(?<=Simple mixer control ').+(?=')")
    do
        _echo "Unmuting ${channel} to 100%"
        amixer set "${channel}" unmute > /dev/null 2>&1
        amixer set "${channel}" 100% > /dev/null 2>&1
    done
}

_write_asoundrc() {
    printf 'defaults.ctl.card %s\ndefaults.pcm.card %s\n' "${1}" "${1}" > "${HOME}/.asoundrc"
}

_switch_card() {
    _search="$(grep -iwH "^${1}$" /proc/asound/card*/id)"
    if [ -n "${_search}" ]
    then
        _index="$(_echo "${_search%:*}" | grep -oP '(?<=/proc/asound/card)[0-9]+(?=/id)')"
        _write_asoundrc "${_index}"
        _echo "Switched to card ${_search##*:} (${_index})"
    else
        _echo "Card ${1} not found, exiting."
        exit 1
    fi
}

_list() {
    _default="$(amixer info | grep -oP "(?<=Card default ').+?(?='/)")"
    cat /proc/asound/card*/id | while IFS= read -r name
    do
        if [ "${name}" = "${_default}" ]
        then
            _echo "+ ${name}"
        else
            _echo "  ${name}"
        fi
    done
    exit 1
}

_play_sound() {
    aplay "${HOME}/arch/sounds/notify.wav" > /dev/null 2>&1 &
}

case "${1}" in
list|l)
    _list
    ;;
*)
    _switch_card "${1}"
    _unmute_max_all
    _play_sound
    ;;
esac

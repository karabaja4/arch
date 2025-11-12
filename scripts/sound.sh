#!/bin/sh

# speaker-test -D hdmi:CARD=NVidia,DEV=0 -c 2 -t wav

_handle_signal() {
    printf '\n%s\n' 'No choice has been made, goodbye.'
    exit 1
}

trap _handle_signal HUP INT QUIT TERM

_aplay_empty_home="/tmp/aplay-empty-home"
rm -rf "${_aplay_empty_home}"
mkdir -p "${_aplay_empty_home}"

_aplay_default() {
    HOME="${_aplay_empty_home}" aplay -l
}

_aplay="$(_aplay_default | grep '^card ')"

_asoundrc_path="${HOME}/.asoundrc"
_asoundrc_content=''

if [ -f "${_asoundrc_path}" ]
then
    _asoundrc_content="$(cat "${_asoundrc_path}")"
fi

# read current indexes from asoundrc and try to match them up to aplay
_current_index=''
if [ -n "${_asoundrc_content}" ]
then
    _current_card="$(printf '%s\n' "${_asoundrc_content}" | grep '^defaults.pcm.card' | awk '{print $NF}')"
    _current_device="$(printf '%s\n' "${_asoundrc_content}" | grep '^defaults.pcm.device' | awk '{print $NF}')"
    if [ -n "${_current_card}" ] && [ -n "${_current_device}" ]
    then
        _current_index="$(printf '%s\n' "${_aplay}" | grep -n "card ${_current_card}:.*device ${_current_device}:" | cut -d: -f1)"
    fi
fi

_choices="$(printf '%s\n' "${_aplay}" | awk -F'[][]' '{print $2 " - " $4}' | nl -w1 -s ') ')"

if [ "${1}" = "l" ] || [ "${1}" = "-l" ] || [ -z "${1}" ]
then
    # print the numbered list only in list mode or select mode
    # mark the line that matched
    if [ -n "${_current_index}" ]
    then
        printf '%s\n' "${_choices}" | sed "${_current_index}s/^/*/"
    else
        printf '%s\n' "${_choices}"
    fi
fi

# list mode, exit
if [ "${1}" = "l" ] || [ "${1}" = "-l" ]
then
    exit 0
fi

_ln=''
if [ -z "${1}" ]
then
    while [ -z "${_ln}" ] || ! printf '%s\n' "${_choices}" | grep -q "^${_ln}) "
    do
        printf 'Choose a device: '
        read -r _ln
    done
else
    _auto_choice="$(printf '%s\n' "${_choices}" | grep -i -F "${1}")"
    _match_count="$(printf '%s\n' "${_auto_choice}" | grep -c -v '^[[:space:]]*$')"
    if [ "${_match_count}" -ne 1 ]
    then
        printf 'Found %s matches for "%s"\n' "${_match_count}" "${1}"
        exit 1
    else
        _ln="$(printf '%s\n' "${_auto_choice}" | cut -d')' -f1)"
    fi
fi

printf 'Selected: %s\n' "$(printf '%s\n' "${_choices}" | sed -n "${_ln}p" | sed 's/^[0-9]*) //')"

_aplay_row="$(printf '%s\n' "${_aplay}" | sed -n "${_ln}p")"

_card="$(printf '%s\n' "${_aplay_row}" | sed -n 's/.*card \([0-9][0-9]*\):.*/\1/p')"
_device="$(printf '%s\n' "${_aplay_row}" | sed -n 's/.*device \([0-9][0-9]*\):.*/\1/p')"

printf 'defaults.ctl.card %s\ndefaults.pcm.card %s\ndefaults.pcm.device %s\n' "${_card}" "${_card}" "${_device}" > "${_asoundrc_path}"
printf 'Device index: card %s, device %s\n' "${_card}" "${_device}"

_get_pvolume_controls() {
    amixer | awk '
        /^Simple mixer control/ {
            split($0, a, "'\''")
            name = a[2]
        }
        /Capabilities:/ {
            for (i = 2; i <= NF; i++)
                if ($i == "pvolume")
                    print name
        }'
}

# unmute and max all channels that support pvolume
for _channel in $(_get_pvolume_controls)
do
    printf 'Unmuting %s to 100%%\n' "${_channel}"
    amixer set "${_channel}" unmute > /dev/null 2>&1
    amixer set "${_channel}" 100% > /dev/null 2>&1
done

# unmute S/PDIF 0 if present
_iec="IEC958,0"
if amixer get "${_iec}" > /dev/null 2>&1
then
    printf "Unmuting %s\n" "${_iec}"
    amixer set "${_iec}" unmute > /dev/null 2>&1
fi

# play embedded sound
_root="$(dirname "$(readlink -f "${0}")")"
aplay "${_root}/../misc/notify.wav" &

#!/bin/sh

_asoundrc="${HOME}/.asoundrc"

# remove so if it's invalid don't get in the way of aplay
rm -f "${_asoundrc}"

_aplay="$(aplay -l | grep '^card ')"
_choices="$(printf '%s\n' "${_aplay}" | sed 's/.*\[\([^]]*\)\].*\[\([^]]*\)\].*/\1 - \2/' | nl -w1 -s ') ')"

_ln=''
if [ -z "${1}" ]
then
    printf '%s\n' "${_choices}"
    while [ -z "${_ln}" ] || ! printf '%s\n' "${_choices}" | grep -q "^${_ln}) "
    do
      printf 'Choose a device: '
      read -r _ln
    done
else
    _auto_choice="$(printf '%s\n' "${_choices}" | grep -i "${1}")"
    _match_count="$(printf '%s\n' "${_auto_choice}" | grep -c -v '^\s*$')"
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

printf 'defaults.ctl.card %s\ndefaults.pcm.card %s\ndefaults.pcm.device %s\n' "${_card}" "${_card}" "${_device}" > "${_asoundrc}"
printf 'Device index: card %s, device %s\n' "${_card}" "${_device}"

# unmute and max all channels that support pvolume
for _channel in $(amixer | grep -P -B1 "^.*Capabilities:.* pvolume( .*$|$)" | grep -oP "(?<=Simple mixer control ').+(?=')")
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
    amixer set "${_iec}" unmute > /dev/null
fi

_dir="$(dirname "$(readlink -f "${0}")")"
aplay "${_dir}/notify48k.wav" > /dev/null 2>&1 &

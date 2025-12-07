#!/bin/sh
_root="$(dirname "$(readlink -f "${0}")")"
. "${_root}/_lib.sh"

_loop="
PG32UCDM
EarPods
BT-W3
"

_selections=''

_loop="$(_nel "${_loop}")"
_out="$("${_root}"/sound.sh l)"

# loop through preconfigured _loop items and make a list of lines from snd that matched each item
for _item in ${_loop}
do
    _result="$(_echo "${_out}" | grep -i -F "${_item}")"
    if [ -n "${_result}" ]
    then
        _selections="$(printf '%s\n%s' "${_selections}" "${_result}")"
    fi
done
_selections="$(_nel "${_selections}")"

if [ -z "${_selections}" ]
then
    _echo "No devices matched."
    exit 1
fi

_selected_and_next="$(_echo "${_selections}" | grep -A1 '^\*')"
_lc="$(_nelc "${_selected_and_next}")"

if [ "${_lc}" -eq 2 ]
then
    # selected is non-last line, select the one after the line with the asterisk
    _to_select="$(_echo "${_selected_and_next}" | tail -n1)"
else
    # selected is last (or only), _lc = 1
    # or nothing is selected, _lc = 0
    # take the first line, remove asterisk (in case of only one option that's selected)
    _to_select="$(_echo "${_selections}" | head -n1 | sed 's/^\*//')"
fi

_color_echo 35 "Selecting: ${_to_select}"
"${_root}"/sound.sh "${_to_select}" 85

# send notification
_herbe "Selected audio device: ${_to_select#*) }"

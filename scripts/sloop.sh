#!/bin/sh
_root="$(dirname "$(readlink -f "${0}")")"
. "${_root}/_lib.sh"

_loop="
pg
logi
w3
"

_selections=''

_loop="$(_echo "${_loop}" | _nel)"
_out="$("${_root}"/sound.sh l)"

# loop through preconfigured _loop items and make a list of lines from snd that matched each item
for _item in ${_loop}
do
    _result="$(_echo "${_out}" | grep -i "${_item}")"
    if [ -n "${_result}" ]
    then
        _selections="$(printf '%s\n%s' "${_selections}" "${_result}")"
    fi
done
_selections="$(_echo "${_selections}" | _nel)"

if [ -z "${_selections}" ]
then
    _echo "No devices matched."
    exit 1
fi

_color_blue="$(printf '\033\[94m')"
_color_reset="$(printf '\033\[0m')"

_selected_and_next="$(_echo "${_selections}" | grep -A1 "^${_color_blue}.*${_color_reset}$")"
_lc="$(_echo "${_selected_and_next}" | _nelc)"

if [ "${_lc}" -eq 2 ]
then
    # selected is non-last line, select the one after the blue line
    # is not blue, so no need to remove color
    _to_select="$(_echo "${_selected_and_next}" | tail -n1)"
else
    # selected is last (or only), _lc = 1
    # nothing is selected, _lc = 0
    # take the first line, remove color
    _to_select="$(_echo "${_selections}" | head -n1 | sed "s/${_color_blue}//g; s/${_color_reset}//g")"
fi

_color_echo 35 "Selecting: ${_to_select}"
"${_root}"/sound.sh "${_to_select}"

# send notification
_herbe "Now playing: ${_to_select#*) }"

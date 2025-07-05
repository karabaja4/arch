#!/bin/sh
set -eu

export XAUTHORITY="${HOME}/.local/share/sx/xauthority"
export DISPLAY=":1"

_key="F13"

while true
do
    _id="$(xdotool search --name "FreeRDP" | head -n1)"
    if [ -n "${_id}" ]
    then
    	printf '%s\n' "Sending ${_key} to ${_id}"
    	xdotool key --window "${_id}" "${_key}"
    	sleep 60
    fi
done

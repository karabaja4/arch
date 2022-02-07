#!/bin/sh

_run() {
    exec "${@}" > /dev/null 2>&1
}

_ffid="$(wmctrl -lx | awk '$3 == "Navigator.firefox" {print $1;exit}')"
if [ -z "${_ffid}" ]
then
    _run firefox "${1}"
else
    printf '%s' "${1}" | xclip -i -selection clipboard
    xdotool windowactivate "${_ffid}"
    xdotool key --window "${_ffid}" ctrl+shift+0
fi

#!/bin/sh

# dependencies:
# https://addons.mozilla.org/en-US/firefox/addon/multiple-paste-and-go-button/

_run() {
    exec "${@}" > /dev/null 2>&1
}

_windowid="$(wmctrl -lx | awk '$3 == "Navigator.firefox" {print $1;exit}')"
if [ -z "${_windowid}" ]
then
    # firefox not running, start new instance
    _run firefox "${@}"
else
    if [ -z "${1}" ]
    then
        # firefox running and new empty window has been requested
        xdotool key --window "${_windowid}" ctrl+n
    else
        # firefox running and url was opened
        printf '%s\n' "${@}" | xclip -i -selection clipboard
        xdotool windowactivate "${_windowid}"
        xdotool key --window "${_windowid}" ctrl+shift+v
    fi
fi

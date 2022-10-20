#!/bin/sh

_p1="$(printf '%s' "${1}" | sed 's;file://;;g' | sed 's;%20; ;g')"
_p2="$(realpath "${_p1}")"

exec xfce4-terminal --title "$(whoami)@$(hostname):${_p2}" --execute bash -c "lf '${_p2}';bash"

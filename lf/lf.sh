#!/bin/sh

_p1="$(printf '%s' "${1}" | sed 's;file://;;g')"
_p2="$(realpath "${_p1}")"

xfce4-terminal --title "lf" --command "lf '${_p2}'"
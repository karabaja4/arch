#!/bin/sh

_p1="$(printf '%s' "${1}" | sed 's;file://;;g' | sed 's;%20; ;g')"
_p2="$(realpath "${_p1}")"
_title="$(whoami)@$(cat /etc/hostname):${_p2}"

exec st -t "${_title}" -e bash -c "lf '${_p2}'; exec bash"

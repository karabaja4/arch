#!/bin/sh

_p1="$(printf '%s' "${1}" | sed 's;file://;;g' | sed 's;%20; ;g')"
_p2="$(realpath "${_p1}")"

exec /usr/local/bin/termite2 --title "$(whoami)@$(hostname):${_p2}" --exec "bash -c \"lf '${_p2}';bash\""

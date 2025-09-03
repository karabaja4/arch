#!/bin/sh

_py="oled.py"

_root="$(dirname "$(readlink -f "$0")")"
_pids="$(pgrep -fx "python3 ${_root}/${_py} -m")"

if [ -n "${_pids}" ]
then
    printf '%s\n' "${_pids}" | xargs -n1 kill
else
    ( python3 "${_root}/${_py}" -m & ) > /dev/null 2>&1
fi

#!/bin/sh

_py="oled.py"

_root="$(dirname "$(readlink -f "$0")")"
_pids="$(pgrep -fx "python3 ${_root}/${_py} -m")"

if [ -z "${_pids}" ]
then
    ( python3 "${_root}/${_py}" -m & ) > /dev/null 2>&1
else
    printf '%s\n' "${_pids}" | xargs -n1 kill
fi

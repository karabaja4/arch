#!/bin/sh
set -eu

_echo() {
    printf '=> %s\n' "${1}"
}

# root check
_not_root() {
    _echo "Must be root"
    exit 1
}

[ "$(id -u)" -ne 0 ] && _not_root

# param check
if [ -z "${1}" ]
then
    _echo "Needs a parameter"
    exit 1
fi

# mountpoint check
if ! mountpoint "${1}" > /dev/null 2>&1
then
    _echo "${1} is not a mountpoint"
    exit 2
fi

_kill() {
    _signal="TERM"
    _exe="$(readlink "/proc/${1}/exe")"
    if [ "${_exe}" = "/usr/bin/bash" ]
    then
        # bash ignores TERM
        _signal="HUP"
    fi
    _echo "Sending ${_signal} to ${1} (${_exe})"
    /usr/bin/kill --verbose --signal "${_signal}" --timeout 20000 KILL "${1}"
}

_get_pids() {
    fuser -Mv "${1}" 2>/dev/null
}

for _pid in $(_get_pids "${1}")
do
    case "${_pid}" in
        ''|*[!0-9]*)
            # ignore non-integers
            ;;
        *)
            _kill "${_pid}"
            ;;
    esac
done

umount -qv "${1}"
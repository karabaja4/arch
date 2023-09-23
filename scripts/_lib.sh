#!/bin/sh
IFS='
'

_echo() {
    printf '%s\n' "${@}"
}

_passwd() {
    _u="$(users)"
    _uc="$(_echo "${_u}" | wc -w)"
    if [ "${_uc}" -ne 1 ]
    then
        _echo "Cannot find a single logged in user" >&2
        exit 103
    fi
    _echo "$(getent passwd "${_u}" | cut -d ':' -f "${1}")"
}

_check_root() {
    if [ "$(id -u)" -ne 0 ]
    then
        _echo "Root privileges are required to run this command" >&2
        exit 100
    fi
}

# 3x - dark
# 9x - light
# 0 - black
# 1 - red
# 2 - green
# 3 - orange
# 4 - blue
# 5 - purple
# 6 - cyan
# 7 - white
_color_echo() {
    printf '\033[%sm%s\033[0m\n' "${1}" "${2}"
}

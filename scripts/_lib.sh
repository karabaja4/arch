#!/bin/sh
set -u
IFS='
'

_echo() {
    printf '%s\n' "${@}"
}

_err() {
    _echo "${1}" >&2
    exit "${2:-255}"
}

_passwd() {
    __u="$(users)"
    __uc="$(_echo "${__u}" | wc -w)"
    if [ "${__uc}" -ne 1 ]
    then
        _err "Cannot find a single logged in user." 100
    fi
    _echo "$(getent passwd "${__u}" | cut -d ':' -f "${1}")"
}

_check_root() {
    if [ "$(id -u)" -ne 0 ]
    then
        _err "Root privileges are required to run this command." 101
    fi
}

_arg1="${1-}"
_arg2="${2-}"
_arg3="${3-}"
_arg4="${4-}"
_arg5="${5-}"

_check_arg() {
    __larg1="${1-}"
    __larg2="${2-}"
    if [ -z "${__larg1}" ]
    then
        _err "Invalid parameter." 102
    fi
    if [ -z "${__larg2}" ]
    then
        _err "This function needs 2 arguments" 103
    fi
    __found=0
    __param_list=$(_echo "${__larg2}" | tr '|' '\n')
    for __param in ${__param_list}
    do
        if [ "${__larg1}" = "${__param}" ]
        then
            __found=1
        fi
    done
    if [ "${__found}" -eq 0 ]
    then
        _err "Invalid parameter." 104
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

# a-1  -> set "a" value to 1 only if a is unset
# a:-1 -> set "a" value to 1 if "a" is unset or "a" is equal to ""
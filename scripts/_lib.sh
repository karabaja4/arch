#!/bin/sh
set -u
IFS='
'

_echo() {
    printf '%s\n' "${@}"
}

_err() {
    __ec="${1-}"
    if [ -z "${__ec}" ]
    then
        _echo "This function needs an argument."
        exit 255
    fi
    case "${__ec}" in
        ''|*[!0-9]*)
            _echo "Invalid exit code (not integer)."
            exit 255
            ;;
        *)
            if [ "${__ec}" -ge 0 ] && [ "${__ec}" -le 255 ]
            then
                if [ "${#}" -gt 1 ]
                then
                    shift
                    _echo "${@}" >&2
                fi
                exit "${__ec:-255}"
            else
                _echo "Invalid exit code (not between 0-255)."
                exit 255
            fi
            ;;
    esac
}

_passwd() {
    __u="$(users)"
    __uc="$(_echo "${__u}" | wc -w)"
    if [ "${__uc}" -ne 1 ]
    then
        _err 200 "Cannot find a single logged in user."
    fi
    _echo "$(getent passwd "${__u}" | cut -d ':' -f "${1}")"
}

_check_root() {
    if [ "$(id -u)" -ne 0 ]
    then
        _err 201 "Root privileges are required to run this command."
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
        _err 202 "Invalid parameter."
    fi
    if [ -z "${__larg2}" ]
    then
        _err 203 "This function needs 2 arguments"
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
        _err 204 "Invalid parameter."
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
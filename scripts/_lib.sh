#!/bin/sh
set -u
IFS='
'

# prints current script path
_script_path() {
    readlink -f "${0}"
}

# prints current dir
_script_dir() {
    dirname "$(_script_path)"
}

# prints current script file name
_script_filename() {
    basename "$(_script_path)"
}

# if script is symlinked, prints link name
# otherwise prints script name
_script_ln() {
    basename "${0}"
}

# print text
# usage: _echo "<text1>" "<text2>"
# each parameter will be printed as a new line
_echo() {
    for __line in "${@}"
    do
        printf '%s\n' "${__line}"
    done
}

# prints colored text
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
    __color_code="${1}"
    shift
    for __color_line in "${@}"
    do
        printf '\033[%sm%s\033[0m\n' "${__color_code}" "${__color_line}"
    done
}

# non-empty line count
_nelc() {
    if [ "${#}" -eq 0 ]
    then
        grep -c -v '^[[:space:]]*$'
    else
        _echo "${@}" | grep -c -v '^[[:space:]]*$'
    fi
}

# exit with an error and print text to stderr
# usage: _err <exit-code> <exit-text>
_err() {
    __ec="${1-}"
    if [ -z "${__ec}" ]
    then
        _err 255 "This function needs an argument."
    fi
    case "${__ec}" in
        ''|*[!0-9]*)
            _err 255 "Invalid exit code (not integer)."
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
                _err 255 "Invalid exit code (not between 0-255)."
            fi
            ;;
    esac
}

# gets the passwd column for the single logged in user
# usage: _passwd <passwd-index>
# for example, _passwd 6 will get the 6th column from the user's passwd, that is, a user's home directory
# if there is more than one logged in user or there is no value in the column, exit with an error
_passwd() {
    __idx="${1-}"
    if [ -z "${__idx}" ]
    then
        _err 200 "This function needs an argument."
    fi
    __u="$(users | tr ' ' '\n' | sort -u)"
    __uc="$(_nelc "${__u}")"
    if [ "${__uc}" -ne 1 ]
    then
        _err 201 "Cannot find a single logged in user (${__uc})."
    fi
    __col="$(getent passwd "${__u}" | cut -d ':' -f "${__idx}")"
    if [ -z "${__col}" ]
    then
        _err 202 "Invalid passwd column."
    fi
    _echo "${__col}"
}

# exits if the current user is not root
_must_be_root() {
    if [ "$(id -u)" -ne 0 ]
    then
        _err 203 "Root privileges are required to run this command."
    fi
}

_arg1="${1-}"
_arg2="${2-}"
_arg3="${3-}"
_arg4="${4-}"
_arg5="${5-}"

# checks arguments
# usage: _check_arg "<arg-to-check>" "<valid-arg1>|<valid-arg2>|<valid-arg3>"
# if the argument is not valid, exit with an error
_check_arg() {
    __larg1="${1-}"
    __larg2="${2-}"
    if [ -z "${__larg1}" ]
    then
        _err 204 "Invalid parameter."
    fi
    if [ -z "${__larg2}" ]
    then
        _err 205 "This function needs 2 arguments"
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
        _err 206 "Invalid parameter."
    fi
}

# a-1  -> set "a" value to 1 only if a is unset
# a:-1 -> set "a" value to 1 if "a" is unset or "a" is equal to ""

_herbe() {
    if command -v herbe > /dev/null 2>&1
    then
        ( XAUTHORITY="$(_passwd 6)/.local/share/sx/xauthority" DISPLAY=":1" herbe "${@}" & ) > /dev/null 2>&1
    fi
}

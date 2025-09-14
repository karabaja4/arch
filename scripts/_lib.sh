#!/bin/sh
set -u
IFS='
'

# a-1  -> set "a" value to 1 only if a is unset
# a:-1 -> set "a" value to 1 if "a" is unset or "a" is equal to ""
_arg1="${1-}"
_arg2="${2-}"
_arg3="${3-}"
_arg4="${4-}"
_arg5="${5-}"

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

_info() {
    _color_echo 94 "${@}"
}

_fatal() {
    _color_echo 91 "${@}" >&2
    exit 9
}

# logging to stdout and to files simultaneously
__script_name="$(basename "${0}")"
_log_lines() {
    for __log_line in "${@}"
    do
        printf '[%s][%s] %s\n' "${__script_name}" "$(date -Is)" "${__log_line}"
    done
}

__log_dir="${HOME}/.local/share/logs"
_log() {
    mkdir -p "${__log_dir}"
    [ ! -w "${__log_dir}" ] && _fatal "${__log_dir} is not writable."
    __log_file="${__log_dir}/${__script_name%.*}.log"
    if [ "${#}" -eq 0 ]
    then
        while IFS= read -r __stdin_line
        do
            _log_lines "${__stdin_line}"
        done | tee -a "${__log_file}"
    else
        _log_lines "${@}" | tee -a "${__log_file}"
    fi
}

# gets the passwd column for the single logged in user
# usage: _passwd <passwd-index>
# for example, _passwd 6 will get the 6th column from the user's passwd, that is, a user's home directory
# if there is more than one logged in user or there is no value in the column, exit with an error
_passwd() {
    __idx="${1-}"
    if [ -z "${__idx}" ]
    then
        _fatal "This function needs an argument."
    fi
    __u="$(users | tr ' ' '\n' | sort -u)"
    __uc="$(_nelc "${__u}")"
    if [ "${__uc}" -ne 1 ]
    then
        _fatal "Cannot find a single logged in user (${__uc})."
    fi
    __col="$(getent passwd "${__u}" | cut -d ':' -f "${__idx}")"
    if [ -z "${__col}" ]
    then
        _fatal "Invalid passwd column."
    fi
    _echo "${__col}"
}

_must_be_root() {
    if [ "$(id -u)" -ne 0 ]
    then
        _fatal "Root privileges are required to run this command."
    fi
}

_must_not_run() {
    if pgrep -x "${1}" > /dev/null
    then
        _fatal "${1} is running, cannot continue."
    fi
}

_herbe() {
    if command -v herbe > /dev/null 2>&1
    then
        ( XAUTHORITY="$(_passwd 6)/.local/share/sx/xauthority" DISPLAY=":1" herbe "${@}" & ) > /dev/null 2>&1
    fi
}

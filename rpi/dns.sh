#!/bin/sh
set -eu

_fn="$(basename "${0}")"
_fd="$(dirname "$(readlink -f "${0}")")"

_logfile="${_fd}/dns.log"
_secret="/etc/secret/secret.json"

_record="$(jq -r ".dns .record" "${_secret}")"
_token="$(jq -r ".dns .token" "${_secret}")"
_ctype="Content-Type: application/json"
_auth="Authorization: Bearer ${_token}"

_echo() {
    printf '[\033[35m%s\033[0m] %s\n' "${_fn}" "${1}"
    printf '[%s][%s] %s\n' "${_fn}" "$(date -Is)" "${1}" >> "${_logfile}"
}

_get_current_ip() (
    curl -s -f "https://avacyn.radiance.hr/ip" || exit 1
)

_get_do_ip() (
    _result="$(curl -s -f -X GET -H "${_ctype}" -H "${_auth}" "${_record}")" || exit 2
    printf "%s" "${_result}" | jq -r ".domain_record .data"
)

_update_do_ip() (
    _result="$(curl -s -f -X PUT -H "${_ctype}" -H "${_auth}" -d "{\"data\":\"${1}\"}" "${_record}")" || exit 3
    printf "%s" "${_result}" | jq -r ".domain_record .data"
)

_exit() {
    _echo "Exit ${1}"
    exit "${1}"
}

# clean up after file gets over 50MB, keep last 6000 lines
_cleanup() {
    _logsize="$(stat -c %s "${_logfile}" 2>/dev/null || printf '%s\n' 0)"
    if [ "${_logsize}" -gt 52428800 ]
    then
        tail -n 6000 "${_logfile}" > "${_logfile}.temp"
        mv "${_logfile}.temp" "${_logfile}"
        _echo "Cleaned up log file."
    fi
}

_run() {
    _echo "Secret: ${_secret}"
    _echo "Record: ${_record}"

    _current_ip="$(_get_current_ip)" || _exit "${?}"
    _do_ip="$(_get_do_ip)" || _exit "${?}"

    _echo "Current IP: ${_current_ip}"
    _echo "DigitalOcean IP: ${_do_ip}"

    if [ "${_current_ip}" != "${_do_ip}" ]
    then
        _new_ip="$(_update_do_ip "${_current_ip}")" || _exit "${?}"
        _echo "Updated ${_record} to ${_new_ip}"
    else
        _echo "Already up to date"
    fi
    _exit 0
}

_cleanup
_run

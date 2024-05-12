#!/bin/sh
set -eu

_fn="$(basename "${0}")"
_fd="$(dirname "$(readlink -f "${0}")")"

_echo() {
    printf '[\033[35m%s\033[0m] %s\n' "${_fn}" "${1}"
    printf '[%s][%s] %s\n' "${_fn}" "$(date -Is)" "${1}" >> "${_fd}/dns.log"
}

_secret="/etc/secret/secret.json"
_record=$(jq -r ".dns .record" "${_secret}")
_token=$(jq -r ".dns .token" "${_secret}")

_echo "Secret: ${_secret}"
_echo "Record: ${_record}"

_get_current_ip() (
    curl -s -f "https://avacyn.radiance.hr/ip" || exit 1
)

_ctype="Content-Type: application/json"
_auth="Authorization: Bearer ${_token}"

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

_run() {
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

_run

#!/bin/bash
set -euo pipefail

declare _secret
declare _record
declare _token
declare -a _headers

_secret="/home/igor/arch/secret.json"
_record=$(jq -r ".dns .record" "${_secret}")
_token=$(jq -r ".dns .token" "${_secret}")
_headers=("-H" "Content-Type: application/json" "-H" "Authorization: Bearer ${_token}")

echo "Secret: ${_secret}"
echo "Record: ${_record}"

_get_current_ip() {
    curl -s -f "https://api.ipify.org"
}

_get_do_ip() {
    curl -s -f -X GET "${_headers[@]}" "${_record}" | jq -r ".domain_record .data"
}

_update_do_ip() {
    curl -s -f -X PUT "${_headers[@]}" -d "{\"data\":\"${1}\"}" "${_record}" | jq -r ".domain_record .data"
}

_fatal() {
    echo "${1}"
    exit 1
}

_run() {
    local _current_ip
    local _do_ip
    local _new_ip

    _current_ip="$(_get_current_ip)" || _fatal "Get current IP failed (${?})"
    _do_ip="$(_get_do_ip)" || _fatal "Get DO IP failed (${?})"

    echo "Current IP: ${_current_ip}"
    echo "DigitalOcean IP: ${_do_ip}"
    
    if [[ "${_current_ip}" != "${_do_ip}" ]]
    then
        _new_ip="$(_update_do_ip "${_current_ip}")" || _fatal "Update DO IP failed (${?})"
        echo "Updated ${_record} to ${_new_ip}"
    else
        echo "Already up to date"
    fi
}

_run
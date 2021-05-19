#!/bin/bash
# shellcheck disable=SC2155

set -euo pipefail
declare -r _secret="/home/igor/arch/secret.json"

declare -r _record=$(jq -r ".dns .record" "${_secret}")
declare -r _token=$(jq -r ".dns .token" "${_secret}")
declare -ar headers=("-H" "Content-Type: application/json" "-H" "Authorization: Bearer ${_token}")

echo "Configuration: ${_secret}"

_get_current_ip() {
    curl -s -f "https://api.ipify.org"
}

_get_do_ip() {
    curl -s -f -X GET "${headers[@]}" "${_record}" | jq -r ".domain_record .data"
}

_update_do_ip() {
    curl -s -f -X PUT "${headers[@]}" -d "{\"data\":\"${1}\"}" "${_record}" | jq -r ".domain_record .data"
}

_run() {
    local _current
    local _do
    _current="$(_get_current_ip)"
    _do="$(_get_do_ip)"
    echo "Current IP: ${_current}"
    echo "DigitalOcean IP: ${_do}"
    if [[ "${_current}" != "${_do}" ]]
    then
        local -r _updated="$(_update_do_ip "${_current}")"
        echo "Updated ${_record} to ${_updated}"
    else
        echo "Already up to date"
    fi
}

_run
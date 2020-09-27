#!/bin/bash
set -euo pipefail

declare -r basedir="$(dirname "$(readlink -f "${0}")")"
declare -r token="$(cat "${basedir}/secret.json" | jq -r ".DNSToken")"
declare -r url="https://api.digitalocean.com/v2/domains/aerium.hr/records/53478297"
declare -ar headers=("-H" "Content-Type: application/json" "-H" "Authorization: Bearer ${token}")

log () {
    echo "[$(date -Is)]: ${1}"
}

declare -r ip="$(curl -s -f "https://api.ipify.org")"
if [ ${?} -eq 0 ]
then
    declare -r dns="$(curl -s -f -X GET "${headers[@]}" "${url}" | jq -r ".domain_record .data")"
    if [ ${?} -eq 0 ]
    then
        if [ "${ip}" == "${dns}" ]
        then
            log "No update necessary."
            exit 0
        else
            curl -s -f -o /dev/null -X PUT "${headers[@]}" -d "{\"data\":\"${ip}\"}" "${url}"
            if [ $? -eq 0 ]
            then
                log "Updated DigitalOcean DNS: ${ip}"
                exit 0
            fi
        fi
    fi
fi

log "DNS update failed."
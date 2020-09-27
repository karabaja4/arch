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
if [ ${?} -ne 0 ]
then
    log "IP request failed."
    exit 1
else
    declare -r dns="$(curl -s -f -X GET "${headers[@]}" "${url}" | jq -r ".domain_record .data")"
    if [ ${?} -ne 0 ]
    then
        log "DigitalOcean GET domain failed."
        exit 1
    else
        if [ "${ip}" == "${dns}" ]
        then
            log "No update necessary."
            exit 0
        else
            curl -s -f -o /dev/null -X PUT "${headers[@]}" -d "{\"data\":\"${ip}\"}" "${url}"
            if [ $? -ne 0 ]
            then
                log "DigitalOcean PUT domain failed."
                exit 1
            else
                log "Update successful: ${ip}"
                exit 0
            fi
        fi
    fi
fi

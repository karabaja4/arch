#!/bin/bash
set -u

declare -r basedir="$(dirname "$(readlink -f "${0}")")"
declare -r token="$(cat "${basedir}/secret.json" | jq -r ".DNSToken")"
declare -r url="https://api.digitalocean.com/v2/domains/aerium.hr/records/53478297"
declare -ar headers=("-H" "Content-Type: application/json" "-H" "Authorization: Bearer ${token}")
declare ip=""
declare dns=""

end () {
    echo "[$(date -Is)]: ${1} (${2})"
    exit ${2}
}

ip="$(curl -s -f "https://api.ipify.org")" || end "IP request failed." ${?} 
dns="$(curl -s -f -X GET "${headers[@]}" "${url}" | jq -r ".domain_record .data")" || end "DigitalOcean GET domain failed." ${?} 

if [ "${ip}" == "${dns}" ]
then
    log "No update necessary."
else
    curl -s -f -o /dev/null -X PUT "${headers[@]}" -d "{\"data\":\"${ip}\"}" "${url}" || end "DigitalOcean PUT domain failed." ${?}
    log "Update successful: ${ip}"
fi
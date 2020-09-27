#!/bin/bash
set -euo pipefail

declare -r ipf="/tmp/public_ip"
declare -r oldip="$(cat "${ipf}")"
declare -r basedir="$(dirname "$(readlink -f "${0}")")"
declare -r token="$(cat "${basedir}/secret.json" | jq -r ".DNSToken")"
declare -r url="https://api.digitalocean.com/v2/domains/aerium.hr/records/53478297"

echo "Running in ${basedir}"

declare -r ip="$(curl -s -f "https://api.ipify.org")"
if [ $? != 0 ]
then
    echo "IP request failed."
else
    if [ "${ip}" != "${oldip}" ]
    then
        curl -s -f -o /dev/null -X PUT -H "Content-Type: application/json" -H "Authorization: Bearer ${token}" -d "{\"data\":\"${ip}\"}" "${url}"
        if [ $? = 0 ]
        then
            echo "DigitalOcean request successful. New IP: ${ip}"
            echo "$(date): Updated DNS: ${ip}"
            echo "${ip}" > ${ipf}
        else
            echo "DigitalOcean request failed."
        fi
    else
        echo "No changes (${ip})"
    fi
fi

#!/bin/sh
set -u

_auth="$(jq -crM '.endpoints[] | select(.route=="/alerts") | .authorization' "/var/www/discordapi/src/config.json")"
if [ -n "${_auth}" ]
then
    curl -s -X POST 'https://api.radiance.hr/alerts' \
        --header "Authorization: ${_auth}" \
        --header 'Content-Type: application/json' \
        --data-raw "{\"text\": \"Certbot reneweal complete!\nDirectory: ${RENEWED_LINEAGE:-"NOTSET"}\nDomains: ${RENEWED_DOMAINS:-"NOTSET"}\"}"
fi

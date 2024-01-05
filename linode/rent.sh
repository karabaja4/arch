#!/bin/sh
set -u

_auth="$(jq -crM '.authorizationKey' "/var/www/discordapi/src/config.json")"
if [ -n "${_auth}" ]
then
    curl -s -X POST 'https://avacyn.radiance.hr/discord/alerts' \
        --header "Authorization: ${_auth}" \
        --header 'Content-Type: application/json' \
        --data-raw "{\"text\": \"Uplati si stanarinu sa firme!\"}"
fi

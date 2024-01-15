#!/bin/sh
set -u

_echo() {
    printf '[%s] %s\n' "$(date -Is)" "${1}"
}

_auth="$(jq -crM '.endpoints[] | select(.route=="/alerts") | .authorization' "/var/www/discordapi/src/config.json")"
if [ -n "${_auth}" ]
then
    _echo "Sending alert to Discord"
    curl -i -s -f -X POST 'https://api.radiance.hr/alerts' \
        --header "Authorization: ${_auth}" \
        --header 'Content-Type: application/json' \
        --data-raw "{\"text\": \"Uplati si stanarinu sa firme za $(date +%-m). mjesec!\"}"
    _echo "Exited with ${?}"
fi

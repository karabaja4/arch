#!/bin/sh
set -eu

_echo() {
    printf '%s %s\n' "[$(date -Is)]" "${1}"
}

_auth="$(jq -crM '.authorizationKey' "/var/www/discordapi/src/config.json")"
if [ -n "${_auth}" ]
then
    _echo "Sending alert to Discord"
    curl -s -X POST 'https://avacyn.radiance.hr/discord/alerts' \
        --header "Authorization: ${_auth}" \
        --header 'Content-Type: application/json' \
        --data-raw "{\"text\": \"Uplati si stanarinu sa firme za $(date +%-m). mjesec!\"}"
    printf '\n'
    _echo "Exited with ${?}"
fi

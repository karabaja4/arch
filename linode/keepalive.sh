#!/bin/sh
set -u
IFS='
'
_echo() {
    printf '%s\n' "${@}"
}

_config="${HOME}/git/racuni-mailer/src/config.json"

for _item in $(jq -crM '.templates[] | { username, password }' "${_config}")
do
    _username="$(_echo "${_item}" | jq -crM '.username')"
    _password="$(_echo "${_item}" | jq -crM '.password')"
    _echo "[$(date -Is)] ${_username}:"
    curl -s -m 30 -u "${_username}:${_password}" -X 'LIST "" "*"' --url 'imaps://outlook.office365.com:993/INBOX'
    _echo "Exited with ${?}"
done

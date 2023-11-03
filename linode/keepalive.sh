#!/bin/sh
set -eu
IFS='
'
_echo() {
    printf '%s\n' "${@}"
}

_config="${HOME}/git/racuni-mailer/src/config.json"

for _item in $(jq -crM '.templates[] | { sender, password }' "${_config}")
do
    _username="$(_echo "${_item}" | jq -crM '.sender')"
    _password="$(_echo "${_item}" | jq -crM '.password')"
    _echo "[$(date -Is)] ${_username}:"
    curl -s -u "${_username}:${_password}" -X 'LIST "" "*"' --url 'imaps://outlook.office365.com:993/INBOX'
    _echo "Exited with ${?}"
done

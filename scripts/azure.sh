#!/bin/sh
set -eu

_echo() {
    printf '%s\n' "${1}"
}

_passwd() {
    _u="$(users)"
    _uc="$(_echo "${_u}" | wc -w)"
    if [ "${_uc}" -ne 1 ]
    then
        _echo "Cannot find a single logged in user" >&2
        exit 1
    fi
    _echo "$(getent passwd "${_u}" | cut -d ':' -f "${1}")"
}

_home="$(_passwd 6)"
_uid="$(_passwd 3)"

_secret="/etc/secret/secret.json"

_azure() {
    _username="$(jq -crM '.azure.username' "${_secret}")"
    _password="$(jq -crM '.azure.password' "${_secret}")"
    mount -t cifs -o username="${_username}",password="${_password}",uid="${_uid}",dir_mode=0755,file_mode=0644,serverino,nosharesock,actimeo=30 "${@}"
}

_public="${_home}/_public"
_private="${_home}/_private"

mkdir -p "${_public}"
mkdir -p "${_private}"

_azure "//linode.file.core.windows.net/public1" "${_public}"
_azure "//linode.file.core.windows.net/private1" "${_private}"

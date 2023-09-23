#!/bin/sh
set -eu

_echo() {
    printf '%s\n' "${1}"
}

_multiple_users() {
    _echo "Cannot find a single logged in user"
    exit 1
}

_user="$(users)"
_usercount="$(_echo "${_user}" | wc -w)"
[ "${_usercount}" -ne 1 ] && _multiple_users
_passwd="$(getent passwd "${_user}")"

_home="$(_echo "${_passwd}" | cut -d':' -f6)"
_uid="$(_echo "${_passwd}" | cut -d':' -f3)"

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

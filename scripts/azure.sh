#!/bin/sh
set -eu

_uid="1000"
_home="$(getent passwd "${_uid}" | cut -d':' -f6)"

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

_azure "//share.radiance.hr/public1" "${_public}"
_azure "//share.radiance.hr/private1" "${_private}"

#_azure "//linode.file.core.windows.net/public1" "${_public}"
#_azure "//linode.file.core.windows.net/private1" "${_private}"

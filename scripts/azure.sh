#!/bin/sh
set -eu

_uid="$(id -u)"
_gid="$(id -g)"
_secret="${HOME}/arch/secret.json"

_azure() {
    _user="$(jq -crM '.azure.username' "${_secret}")"
    _pass="$(jq -crM '.azure.password' "${_secret}")"
    doas mount -t cifs -o username="${_user}",password="${_pass}",uid="${_uid}",gid="${_gid}",dir_mode=0755,file_mode=0644,serverino,nosharesock,actimeo=30 "${@}"
}

mkdir -p "${HOME}/_public"
mkdir -p "${HOME}/_private"

_azure "//linode.file.core.windows.net/public1" "${HOME}/_public"
_azure "//linode.file.core.windows.net/private1" "${HOME}/_private"

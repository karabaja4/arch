#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"

set -eu

_home="$(_passwd 6)"
_uid="$(_passwd 3)"
_gid="$(_passwd 4)"

if [ -z "${_home}" ] ||  [ -z "${_uid}" ] ||  [ -z "${_gid}" ]
then
    _err 100 "Cannot find user's home or uid or gid."
fi

_secret="/etc/secret/secret.json"
_username="$(jq -crM '.smb.username' "${_secret}")"
_password="$(jq -crM '.smb.password' "${_secret}")"

_mount() {
    mount -t cifs -o username="${_username}",password="${_password}",uid="${_uid}",gid="${_gid}",dir_mode=0755,file_mode=0644 "${@}"
}

_public="${_home}/_public"
_private="${_home}/_private"

mkdir -p "${_public}"
mkdir -p "${_private}"

_mount "//radiance.hr/public" "${_public}"
_mount "//radiance.hr/private" "${_private}"

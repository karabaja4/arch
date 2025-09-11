#!/bin/sh
. "$(dirname "$(readlink -f "${0}")")/_lib.sh"

_home="$(_passwd 6)"
_uid="$(_passwd 3)"
_gid="$(_passwd 4)"

if [ -z "${_home}" ] ||  [ -z "${_uid}" ] ||  [ -z "${_gid}" ]
then
    _fatal "Cannot find user's home or uid or gid."
fi

_secret="/etc/secret/secret.json"
_username="$(jq -crM '.smb.username' "${_secret}")"
_password="$(jq -crM '.smb.password' "${_secret}")"

_mount() {
    _port="${1}"
    shift
    mount -t cifs -o username="${_username}",password="${_password}",uid="${_uid}",gid="${_gid}",dir_mode=0755,file_mode=0644,port="${_port}" "${@}"
}

_public="${_home}/_public"
_private="${_home}/_private"
_disk="${_home}/_disk"

mkdir -p "${_public}"
mkdir -p "${_private}"
mkdir -p "${_disk}"

_mount 44555 "//radiance.hr/public" "${_public}"
_mount 44555 "//radiance.hr/private" "${_private}"
_mount 445 "//192.168.100.33/disk" "${_disk}"

# ssh tunnel
_mount 44555 "//localhost/disk" "${_disk}"

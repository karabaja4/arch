#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"

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

_mount_remote() {
    mount -t cifs -o username="${_username}",password="${_password}",uid="${_uid}",gid="${_gid}",dir_mode=0755,file_mode=0644,port=44555 "${@}"
}

_mount_local() {
    mount -t cifs -o username="${_username}",password="${_password}",uid="${_uid}",gid="${_gid}",dir_mode=0755,file_mode=0644 "${@}"
}

_public="${_home}/_public"
_private="${_home}/_private"
_disk="${_home}/_disk"

mkdir -p "${_public}"
mkdir -p "${_private}"
mkdir -p "${_disk}"

_mount_remote "//radiance.hr/public" "${_public}"
_mount_remote "//radiance.hr/private" "${_private}"
_mount_local "//192.168.100.33/disk" "${_disk}"
_mount_remote "//localhost/disk" "${_disk}"

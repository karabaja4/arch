#!/bin/sh
set -u

_uid="1000"
_gid="1000"
_secret="/home/igor/secret.txt"
_username="$(cat "${_secret}" | sed -n '1p')"
_password="$(cat "${_secret}" | sed -n '2p')"
_public="/home/igor/public"
_private="/home/igor/private"

_mount_remote() {
    mount -t cifs -o username="${_username}",password="${_password}",uid="${_uid}",gid="${_gid}",dir_mode=0755,file_mode=0644,port=44555 "${@}"
}

mountremote() {
    mkdir -p "${_public}"
    mkdir -p "${_private}"
    _mount_remote "//radiance.hr/public" "${_public}"
    _mount_remote "//radiance.hr/private" "${_private}"
}

zero() {
    if [ -z "${1-}" ] || [ ! -b "${1}" ]
    then
        echo "Usage example: zero /dev/nvme0n1" >&2
        return 1
    fi
    dd if=/dev/zero of="${1}" bs=1M
}

backup() {
    if [ -z "${1-}" ] || [ -z "${2-}" ] || [ ! -b "${1}" ]
    then
        echo "Usage example: backup /dev/nvme0n1 /home/igor/private/backups/win" >&2
        return 1
    fi
    dd if="${1}" conv=sync,noerror bs=64K | gzip -c > "${2}.img.gz"
}

restore() {
    if [ -z "${1-}" ] || [ -z "${2-}" ] || [ ! -b "${2}" ]
    then
        echo "Usage example: restore /home/igor/private/backups/win.img.gz /dev/nvme0n1" >&2
        return 1
    fi
    gunzip -c "${1}" | dd of="${2}"
}

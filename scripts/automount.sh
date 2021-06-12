#!/bin/sh
set -u

_echo() {
    printf '%s\n' "${1}"
}

_usage() {
    _echo "This is script is called by /etc/udev/rules.d/10-flash.rules"
    exit 2
}

_not_root() {
    _echo "Root privileges are required to run this command"
    exit 1
}

[ "${#}" -ne 1 ] && _usage
[ "$(id -u)" -ne 0 ] && _not_root

_mount_uid=1000

_mount() (
    _user="$(id -un ${_mount_uid})"
    _dir="/mnt/${1}"
    _uid="$(id -u "${_user}")"
    _gid="$(id -g "${_user}")"
    install -m 0755 -g "${_user}" -o "${_user}" -d "${_dir}"
    mount -o uid="${_uid}",gid="${_gid}" "/dev/${1}" "${_dir}"
)

_enum() {
    _partitions="$(lsblk -J "${1}" | jq -crM '.blockdevices[] | .children[] | select(.type=="part") | .name')"
    _echo "${_partitions}" | while read -r part
    do
        _mount "${part}"
    done
}

( _enum "${1}" & )
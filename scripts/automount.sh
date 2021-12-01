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

_user="$(id -un 1000)"

_mkdir() {
    install -m 0755 -g "${_user}" -o "${_user}" -d "${1}"
}

_mount() (
    _mkdir "/mnt/${_user}"
    _mkdir "/mnt/${_user}/${1}"

    _uid="$(id -u "${_user}")"
    _gid="$(id -g "${_user}")"
    mount -o uid="${_uid}",gid="${_gid}" "/dev/${1}" "/mnt/${_user}/${1}"
)

_enum() {
    for part in $(lsblk -J "${1}" | jq -crM '.blockdevices[] | .children[] | select(.type=="part") | .name')
    do
        _mount "${part}"
    done
}

_enum "${1}" > /dev/null 2>&1 &
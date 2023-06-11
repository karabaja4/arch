#!/bin/sh
set -u

# not -e because we want to try iterate all partitions

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

_get_partitions() {
    _parts="$(lsblk -J "${1}" | jq -crM '.blockdevices[] | select(.children) | .children[] | select(.type=="part") | .name')"
    if [ -n "${_parts}" ]
    then
        _echo "${_parts}"
    else
        # some usb drives have partition on /dev/sdd
        _echo "$(basename "${1}")"
    fi
}

_mount() (
    _mkdir "/mnt/${1}"

    # ntfs, fat32 || ext4 || failed, remove dir
    mount -o uid=1000,fmask=133,dmask=022 "/dev/${1}" "/mnt/${1}" || mount "/dev/${1}" "/mnt/${1}" || rm -r "/mnt/${1:?}"

    # ext4
    chown "${_user}:${_user}" "/mnt/${1}"
)

_enum() {
    for _part in $(_get_partitions "${1}")
    do
        _mount "${_part}"
    done
}

_enum "${1}" > /dev/null 2>&1 &

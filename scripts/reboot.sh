#!/bin/sh
set -u

_echo() {
    printf '%s\n' "${1}"
}

# root check
_not_root() {
    _echo "Must be root"
    exit 1
}

[ "$(id -u)" -ne 0 ] && _not_root

_home="/home/$(id -un 1000)"

killall -q -v -w qbittorrent

_umount() {
    if mountpoint -q "${1}"
    then
        if ! umount -v "${1}"
        then
            _echo "Not rebooting, umount ${1} failed."
            exit 1
        fi
    fi
}

_umount "${_home}/_disk"
_umount "${_home}/_mmc"
_umount "${_home}/_private"
_umount "${_home}/_public"

# cleanup /mnt
/home/igor/arch/scripts/usb.sh

rm -rf "${_home}/.cache"

if [ "${1}" = "reboot" ]
then
    _echo "Rebooting..."
    /usr/bin/reboot
fi

if [ "${1}" = "poweroff" ]
then
    _echo "Powering off..."
    /usr/bin/poweroff
fi

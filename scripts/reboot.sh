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

killall -v -w qbittorrent 2>/dev/null

_umount() {
    /home/igor/arch/scripts/umount.sh "${1}"
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

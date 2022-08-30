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
    umount -qv "${1}"
    if [ "${?}" -eq 32 ]
    then
        # if the target is busy, stop the reboot
        exit 32
    fi
}

umount -qv "${_home}/_disk"
umount -qv "${_home}/_mmc"
umount -qv "${_home}/_private"
umount -qv "${_home}/_public"

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

#!/bin/sh
set -eu

if [ "${#}" -ne 1 ]
then
    printf '%s\n' 'Needs a parameter.'
    exit 1
fi

if [ "${1}" != 'reboot' ] && [ "${1}" != 'poweroff' ]
then
    printf '%s\n' 'Needs a reboot or poweroff parameter.'
    exit 1
fi

_disk='/home/igor/disk'

rc-service qbittorrent-nox stop
rc-service samba stop
rc-service nodexmastree stop
umount "${_disk}" && printf '%s\n' "Unmounted ${_disk}"

if [ "${1}" = 'reboot' ]
then
    printf '%s\n' 'Rebooting...'
    reboot
fi

if [ "${1}" = 'poweroff' ]
then
    printf '%s\n' 'Shutting down...'
    poweroff
fi

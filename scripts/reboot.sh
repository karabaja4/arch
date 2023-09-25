#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"

set -u

# argument check
_check_arg "${_arg1}" "reboot|poweroff"

_check_root

killall -q -v -w qbittorrent

_umount() {
    if mountpoint -q "${1}"
    then
        if ! umount -v "${1}"
        then
            _err 100 "Not rebooting, umount ${1} failed."
        fi
    fi
}

_home="$(_passwd 6)"

for _mp in "${_home}/_"*
do
    _umount "${_mp}"
done

# cleanup /mnt
"${_home}/arch/scripts/usb.sh"

rm -rf "${_home}/.cache"

if [ "${_arg1}" = "reboot" ]
then
    _echo "Rebooting..."
    /usr/bin/reboot
fi

if [ "${_arg1}" = "poweroff" ]
then
    _echo "Powering off..."
    /usr/bin/poweroff
fi

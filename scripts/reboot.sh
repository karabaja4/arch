#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"
set -u

_must_be_root

_umount() {
    if mountpoint -q "${1}"
    then
        if ! umount -v "${1}"
        then
            _fatal "Not rebooting, umount ${1} failed."
        fi
    fi
}

_home="$(_passwd 6)"
if [ -z "${_home}" ]
then
    _fatal "Cannot find user's home."
fi

# cleanup /home/igor/_*
for _mp in "${_home}/_"*
do
    _umount "${_mp}"
done

_root="$(dirname "$(readlink -f "$0")")"

# cleanup /mnt/*
if ! "${_root}/usb.sh"
then
    _fatal "Failed to unmount USB drives."
fi

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

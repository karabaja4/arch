#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"

set -u

# argument check
_check_arg "${_arg1}" "reboot|poweroff"

_must_be_root

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
if [ -z "${_home}" ]
then
    _err 101 "Cannot find user's home."
fi

for _mp in "${_home}/_"*
do
    _umount "${_mp}"
done

# cleanup /mnt
if ! "$(_script_dir)/usb.sh"
then
    _err 101 "Failed to unmount USB drives."
fi

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

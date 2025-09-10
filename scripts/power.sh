#!/bin/sh
. "$(dirname "$(readlink -f "${0}")")/_lib.sh"

_must_be_root

_home="$(_passwd 6)"
if [ ! -d "${_home}" ]
then
    _fatal "Cannot find user's home directory."
fi

_root="$(dirname "$(readlink -f "$0")")"

if ! "${_root}/unmount.sh" /mnt/* "${_home}"/_*
then
    _fatal "Failed to ${_arg1}"
fi

if [ "${_arg1}" = "reboot" ]
then
    _info "Rebooting..."
    /usr/bin/reboot
fi

if [ "${_arg1}" = "poweroff" ]
then
    _info "Powering off..."
    /usr/bin/poweroff
fi

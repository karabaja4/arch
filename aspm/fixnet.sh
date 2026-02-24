#!/bin/sh
set -eu

# https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=279245

if [ "$(id -u)" -ne 0 ]
then
    printf '%s\n' "Must be root."
    exit 1
fi

_device="8086:125c"
_address="$(lspci -d "${_device}" | awk '{ print $1 }')"
if [ -n "${_address}" ]
then
    _current="$(setpci -s "${_address}" b0.b)"
    if [ "${_current}" = "42" ]
    then
        setpci -s "${_address}" b0.w=0040
        printf '[%s] ASPM disabled.\n' "${_address}"
    else
        printf '[%s] Current value %s not valid, exiting.\n' "${_address}" "${_current}"
    fi
else
    printf 'Device %s not found.\n' "${_device}"
    exit 1
fi

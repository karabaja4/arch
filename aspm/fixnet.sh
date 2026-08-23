#!/bin/sh
set -eu

# https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=279245
# https://wireless.docs.kernel.org/en/latest/en/users/documentation/aspm.html

if [ "$(id -u)" -ne 0 ]
then
    printf '%s\n' "Must be root."
    exit 1
fi

_devices_registers="
8086:125c b0
8086:272b 80
"

printf '%s\n' "${_devices_registers}" | grep '.' | while read -r _device _register
do
    _address="$(lspci -d "${_device}" | awk '{ print $1 }')"
    if [ -n "${_address}" ]
    then
        _current="$(setpci -s "${_address}" "${_register}.b")"
        if [ "${_current}" = "42" ]
        then
            setpci -s "${_address}" "${_register}.b=40"
            printf '[%s] ASPM disabled.\n' "${_address}"
        else
            printf '[%s] Current value %s not valid, exiting.\n' "${_address}" "${_current}"
        fi
    else
        printf 'Device %s not found.\n' "${_device}"
    fi
done

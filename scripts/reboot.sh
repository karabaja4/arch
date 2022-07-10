#!/bin/sh
# shellcheck disable=SC2115

_echo() {
    printf '%s\n' "${1}"
}

_not_root() {
    _echo "Must be root"
    exit 1
}

[ "$(id -u)" -ne 0 ] && _not_root

_home="/home/$(id -un 1000)"

_umount() {
    fuser -Mk "${@}"
    umount -qv "${@}"
}

killall -v -w qbittorrent

_umount "${_home}/_disk"
_umount "${_home}/_mmc"
_umount "${_home}/_private"
_umount "${_home}/_public"

for _f in /mnt/*
do
    if [ "${_f}" != "/mnt/*" ]
    then
        _umount "${_f}"
        rm -vrf "${_f}"
    fi
done

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
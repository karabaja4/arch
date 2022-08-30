#!/bin/sh
set -eu

_echo() {
    printf '=> %s\n' "${1}"
}

# root check
_not_root() {
    _echo "Must be root"
    exit 1
}

[ "$(id -u)" -ne 0 ] && _not_root

for _f in /mnt/*
do
    if [ -d "${_f}" ]
    then
        umount -v "${_f}"
        rm -vrf "${_f}"
    fi
done

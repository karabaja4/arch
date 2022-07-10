#!/bin/sh
# shellcheck disable=SC2115
set -u

_umount() {
    fuser -Mk "${@}"
    doas umount -qv "${@}"
}

/usr/bin/kill --verbose --signal TERM --timeout 30000 KILL qbittorrent

_umount "${HOME}/_disk"
_umount "${HOME}/_mmc"
_umount "${HOME}/_private"
_umount "${HOME}/_public"

for _f in /mnt/*
do
    if [ "${_f}" != "/mnt/*" ]
    then
        _umount "${_f}"
        rm -vrf "${_f}"
    fi
done

rm -rf "${HOME}/.cache"

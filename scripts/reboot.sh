#!/bin/sh
# shellcheck disable=SC2115

_echo() {
    printf "$(tput setaf 1)%s$(tput sgr0)\n" "${1}"
}

_umount() {
    fuser -Mk "${@}"
    doas umount -qv "${@}"
}

/usr/bin/kill --verbose --signal TERM --timeout 30000 KILL qbittorrent

_umount "${HOME}/_disk"
_umount "${HOME}/_mmc"
_umount "${HOME}/_private"
_umount "${HOME}/_public"

_umount /mnt/*
rm -vrf /mnt/*

rm -rf "${HOME}/.cache"
_echo "Rebooting!"
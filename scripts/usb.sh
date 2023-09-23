#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"

set -eu

_check_root

for _f in "/mnt/"*
do
    if [ -d "${_f}" ]
    then
        umount -v "${_f}"
        rm -vrf "${_f}"
    fi
done

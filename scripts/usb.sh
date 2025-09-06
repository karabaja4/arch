#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"
set -e

_must_be_root

for _f in "/mnt/"*
do
    if [ -d "${_f}" ]
    then
        umount -v "${_f}"
        rmdir -v "${_f}"
        _herbe "Unmounted ${_f}"
    fi
done

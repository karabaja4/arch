#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"
set -e

_must_be_root

_has_failures=0

for _f in "${@}"
do
    if [ -d "${_f}" ]
    then
        if umount -v "${_f}"
        then
            # pop up herbe for /mnt and do a cleanup
            case "${_f}" in
            /mnt/*)
                rmdir -v "${_f}"
                _herbe "Unmounted ${_f}"
                ;;
            esac
        else
            _has_failures=1
        fi
    fi
done

if [ "${_has_failures}" -ne 0 ]
then
    _echo "Failed to cleanly unmount all devices."
    exit 1
else
    exit 0
fi

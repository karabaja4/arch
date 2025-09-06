#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"
set -e

_must_be_root

_has_failures=0

for _f in "${@}"
do
    # process only dirs
    if [ -d "${_f}" ]
    then
        case "${_f}" in
        /mnt/*)
            # any dir under /mnt must already be mounted, and then unmounted and deleted
            # show notification for those kind of dirs
            if umount -v "${_f}"
            then
                rmdir -v "${_f}"
                _herbe "Unmounted ${_f}"
            else
                _has_failures=1
            fi
            ;;
        *)
            # dirs not under /mnt just need to be unmounted if they're mounted
            if mountpoint -q "${_f}"
            then
                if ! umount -v "${_f}"
                then
                    _has_failures=1
                fi
            fi
            ;;
        esac
    fi
done

if [ "${_has_failures}" -ne 0 ]
then
    _echo "Failed to cleanly unmount all devices."
    exit 1
else
    exit 0
fi

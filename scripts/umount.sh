#!/bin/sh
# shellcheck disable=SC2329
. "$(dirname "$(readlink -f "${0}")")/_lib.sh"

_must_be_root

_failures=0
_failed() {
   _failures=$((_failures + 1))
}

_mounts="$(cat /proc/mounts)"

_umount_cifs() {
    _cifs="$(_echo "${_mounts}" | awk '$3 == "cifs" { print $1 }')"
    for _share in ${_cifs}
    do
        umount -c -v "${_share}" || _failed
    done
}

_umount_home() {
    _home_devices="$(_echo "${_mounts}" | awk '$1 ~ "^/dev/" && $2 ~ "^/home/" { print $1 }')"
    for _device in ${_home_devices}
    do
        umount -c -v "${_device}" || _failed
    done
}

_umount_mnt() {
    _mnt_lines="$(_echo "${_mounts}" | awk '$1 ~ "^/dev/" && $2 ~ "^/mnt/"')"
    for _line in ${_mnt_lines}
    do
        _mnt_device="$(_echo "${_line}" | awk '{print $1}')"
        _mnt_mountpoint="$(_echo "${_line}" | awk '{print $2}')"
        if umount -c -v "${_mnt_device}"
        then
            if rmdir -v "${_mnt_mountpoint}"
            then
                _herbe "Unmounted ${_mnt_mountpoint} (${_mnt_device})"
            else
                _failed
            fi
        else
            _failed
        fi
    done
}

if [ "${#}" -eq 0 ]
then
    set -- cifs home mnt
fi

for _param in "${@}"
do
    _umount_"${_param}"
done

if [ "${_failures}" -gt 0 ]
then
    _echo "Failed to cleanly unmount ${_failures} devices."
    exit 1
fi

exit 0

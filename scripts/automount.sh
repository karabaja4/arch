#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"

# not -e because we want to try to iterate all partitions
set -u

_must_be_root

_usage() {
    _echo "This is script is called by /etc/udev/rules.d/10-flash.rules"
    exit 1
}

[ "${#}" -ne 1 ] && _usage

_user="$(_passwd 1)"

_mkdir() {
    install -m 0755 -g "${_user}" -o "${_user}" -d "${1}"
}

_get_partitions() {
    _parts="$(lsblk --output UUID,KNAME,FSTYPE --json "${1}" | jq -crM '.blockdevices[] | select(.uuid != null) | { uuid, kname, fstype }')"
    if [ -n "${_parts}" ]
    then
        _echo "${_parts}"
    fi
}

_mount() (
    _uuid="$(_echo "${1}" | jq -crM '.uuid')"
    _kname="$(_echo "${1}" | jq -crM '.kname')"
    _fstype="$(_echo "${1}" | jq -crM '.fstype')"

    _devpath="/dev/${_kname}"
    _mntpath="/mnt/${_kname}-${_fstype}-${_uuid}"

    _mkdir "${_mntpath}"

    case "${_fstype}" in
    vfat|ntfs)
        _uid="$(id -u "${_user}")"
        mount -o uid="${_uid}",fmask=133,dmask=022 "${_devpath}" "${_mntpath}"
        ;;
    ext*|jfs|reiserfs|xfs|f2fs|btrfs|nilfs2|hfsplus)
        mount "${_devpath}" "${_mntpath}" && chown "${_user}:${_user}" "${_mntpath}"
        ;;
    *)
        mount "${_devpath}" "${_mntpath}"
        ;;
    esac

    _ec="${?}"
    if [ "${_ec}" -ne 0 ]
    then
        rmdir "${_mntpath}"
    fi
)

_enum() {
    # wait for uuid to populate
    sleep 1
    for _part in $(_get_partitions "${1}")
    do
        _mount "${_part}"
    done
}

( _enum "${1}" & ) > /dev/null 2>&1

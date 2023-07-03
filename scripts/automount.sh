#!/bin/sh
set -u

# not -e because we want to try to iterate all partitions

# don't mount anything on boot
if ! pgrep -x "Xorg" > /dev/null
then
    exit 0
fi

_echo() {
    printf '%s\n' "${1}"
}

_usage() {
    _echo "This is script is called by /etc/udev/rules.d/10-flash.rules"
    exit 2
}

_not_root() {
    _echo "Root privileges are required to run this command"
    exit 1
}

[ "${#}" -ne 1 ] && _usage
[ "$(id -u)" -ne 0 ] && _not_root

_user="$(id -un 1000)"

_mkdir() {
    install -m 0755 -g "${_user}" -o "${_user}" -d "${1}"
}

_get_partitions() {
    _parts="$(lsblk --output UUID,KNAME --json "${1}" | jq -crM '.blockdevices[] | select(.uuid != null) | { uuid, kname }')"
    if [ -n "${_parts}" ]
    then
        _echo "${_parts}"
    fi
}

_mount() (
    _uuid="$(_echo "${1}" | jq -crM '.uuid')"
    _kname="$(_echo "${1}" | jq -crM '.kname')"

    _devpath="/dev/${_kname}"
    _mntpath="/mnt/${_kname}-${_uuid}"

    _mkdir "${_mntpath}"

    # ntfs, fat32 || ext4 || failed, remove dir
    mount -o uid=1000,fmask=133,dmask=022 "${_devpath}" "${_mntpath}" || mount "${_devpath}" "${_mntpath}" || rm -r "${_mntpath}"

    # ext4
    chown "${_user}:${_user}" "${_mntpath}"
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

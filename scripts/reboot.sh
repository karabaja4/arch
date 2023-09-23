#!/bin/sh
set -u

_echo() {
    printf '%s\n' "${1}"
}

# argument check
_arg1="${1-}"
case "${_arg1}" in
reboot|poweroff)
    ;;
*)
    _echo "Invalid argument"
    exit 1
    ;;
esac

# root check
_not_root() {
    _echo "Must be root"
    exit 1
}

[ "$(id -u)" -ne 0 ] && _not_root

killall -q -v -w qbittorrent

_umount() {
    if mountpoint -q "${1}"
    then
        if ! umount -v "${1}"
        then
            _echo "Not rebooting, umount ${1} failed."
            exit 1
        fi
    fi
}

_multiple_users() {
    _echo "Cannot find a single logged in user"
    exit 1
}

_user="$(users)"
_usercount="$(_echo "${_user}" | wc -w)"
[ "${_usercount}" -ne 1 ] && _multiple_users
_home="$(getent passwd "${_user}" | cut -d':' -f6)"

for _mp in "${_home}/_"*
do
    _umount "${_mp}"
done

# cleanup /mnt
"${_home}/arch/scripts/usb.sh"

rm -rf "${_home}/.cache"

if [ "${_arg1}" = "reboot" ]
then
    _echo "Rebooting..."
    /usr/bin/reboot
fi

if [ "${_arg1}" = "poweroff" ]
then
    _echo "Powering off..."
    /usr/bin/poweroff
fi

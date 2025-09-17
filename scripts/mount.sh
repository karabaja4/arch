#!/bin/sh
. "$(dirname "$(readlink -f "${0}")")/_lib.sh"

_must_be_root

_uid="$(_passwd 3)"
_gid="$(_passwd 4)"

if [ -z "${_uid}" ] ||  [ -z "${_gid}" ]
then
    _fatal "Cannot find user's home or uid or gid."
fi

_secret='/etc/secret/secret.json'
_username="$(jq -crM '.smb.username' "${_secret}")"
_password="$(jq -crM '.smb.password' "${_secret}")"

# ${1} = port
# ${2} = remote path
# ${3} = local path
_mount_smb() {
    if [ ! -d "${3}" ]
    then
        install -v -m 755 -g "${_gid}" -o "${_uid}" -d "${3}"
    fi
    if ! mountpoint -q "${3}"
    then
        if mount -t cifs -o username="${_username}",password="${_password}",uid="${_uid}",gid="${_gid}",dir_mode=0755,file_mode=0644,port="${1}" "${2}" "${3}"
        then
            printf 'Mounted [%s][%s] to %s\n' "${1}" "${2}" "${3}"
        else
            printf 'Failed to mount [%s][%s] to %s\n' "${1}" "${2}" "${3}"
            return 1
        fi
    else
        printf '%s is already mounted.\n' "${3}"
        return 2
    fi
}

# ${1} = uuid
# ${2} = local path
_mount_ntfs() {
    if [ ! -d "${2}" ]
    then
        install -v -m 755 -g "${_gid}" -o "${_uid}" -d "${2}"
    fi
    if ! mountpoint -q "${2}"
    then
        # uses kernel ntfs3 driver
        mount -v -t ntfs3 -U "${1}" -o uid="${_uid}",fmask=133,dmask=022 "${2}"
    else
        printf '%s is already mounted.\n' "${2}"
        return 2
    fi
}

_mount_private() {
    _mount_smb '44555' '\\radiance.hr\private' '/home/igor/_private'
}

_mount_public() {
    _mount_smb '44555' '\\radiance.hr\public' '/home/igor/_public'
}

_mount_disk() {
    if nc -z localhost 44555 > /dev/null 2>&1
    then
        # ssh tunnel (traveling)
        _mount_smb '44555' '\\localhost\disk' '/home/igor/_disk'
    else
        # local (home)
        _mount_smb '445' '\\192.168.100.33\disk' '/home/igor/_disk'
    fi
}

_mount_mmc() {
    _mount_ntfs '78DD72146717D509' '/home/igor/_mmc'
}

for _item in "${@}"
do
    _mount_"${_item}"
done

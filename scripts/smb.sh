#!/bin/sh
. "$(dirname "$(readlink -f "${0}")")/_lib.sh"

# ${1} = port
# ${2} = remote path
# ${3} = local path

_uid="$(_passwd 3)"
_gid="$(_passwd 4)"

if [ -z "${_uid}" ] ||  [ -z "${_gid}" ]
then
    _fatal "Cannot find user's home or uid or gid."
fi

_secret="/etc/secret/secret.json"
_username="$(jq -crM '.smb.username' "${_secret}")"
_password="$(jq -crM '.smb.password' "${_secret}")"

if [ ! -d "${3}" ]
then
    install -v -m 755 -g "${_gid}" -o "${_uid}" -d "${3}"
fi

if ! mountpoint -q "${3}"
then
    mount -t cifs -o username="${_username}",password="${_password}",uid="${_uid}",gid="${_gid}",dir_mode=0755,file_mode=0644,port="${1}" "${2}" "${3}"
    printf 'Mounted %s to %s on port %s\n' "${2}" "${3}" "${1}"
else
    printf '%s is already mounted.\n' "${3}"
fi

#!/bin/sh
_root="$(dirname "$(readlink -f "${0}")")"
. "${_root}/_lib.sh"
set -e

# CIFS is unable to re-establish connection on SMB server restart when using a custom port
# DebugData shows DISCONNECTED:

# 1) \\radiance.hr\public
# ...
# ...	DISCONNECTED

# use umount -c to not canonicalize paths
# otherwise umount stalls on a non-responsive path
# as does mountpoint -q, so don't use umount.sh

_must_be_root

_debug_data_path='/proc/fs/cifs/DebugData'

if [ ! -r "${_debug_data_path}" ]
then
    _log "${_debug_data_path} is not readable."
    exit 1
fi

_debug_data="$(cat "${_debug_data_path}")"
_host="radiance.hr"

_check_mount() {
    _remote_path="\\\\${_host}\\${1}"
    if printf '%s\n' "${_debug_data}" | grep -F -A3 "${_remote_path}" | grep -q 'DISCONNECTED'
    then
        nc -z -w2 "${_host}" 44555
        _nc_ec="${?}"
        _log "${_remote_path} is DISCONNECTED (${_nc_ec})"
        if [ "${_nc_ec}" -eq 0 ]
        then
            _local_path="/home/igor/_${1}"
            umount -c -v "${_local_path}" 2>&1 | _log
            "${_root}/mount.sh" "${1}" 2>&1 | _log
        fi
    fi
}

_check_mount 'private'
_check_mount 'public'

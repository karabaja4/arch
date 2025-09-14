#!/bin/sh
_root="$(dirname "$(readlink -f "${0}")")"
. "${_root}/_lib.sh"

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
        if nc -z -w2 "${_host}" 44555 > /dev/null 2>&1
        then
            _nc_ec="0"
            _local_path="/home/igor/_${1}"
            _log "${_remote_path} is DISCONNECTED (nc = ${_nc_ec}), remounting ${_local_path}"
            umount -c -v "${_local_path}" 2>&1 | _log
            "${_root}/mount.sh" "${1}" 2>&1 | _log
        else
            _nc_ec="${?}"
            _log "${_remote_path} is DISCONNECTED (nc = ${_nc_ec}), skip."
        fi
    fi
}

_check_mount 'private'
_check_mount 'public'

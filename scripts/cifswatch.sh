#!/bin/sh
. "$(dirname "$(readlink -f "${0}")")/_lib.sh"
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
_root="$(dirname "$(readlink -f "${0}")")"

_debug_data_path='/proc/fs/cifs/DebugData'

if [ ! -r "${_debug_data_path}" ]
then
    _log "${_debug_data_path} is not readable."
    exit 1
fi

_ping() {
    curl -fs -o /dev/null -w '%{http_code}' \
    --connect-timeout 1 --max-time 3 \
    "https://avacyn.radiance.hr/ip" 2>/dev/null
}

_debug_data="$(cat "${_debug_data_path}")"
_ping_http_code="$(_ping)"

_check_mount() {
    _remote_path="\\\\radiance.hr\\${1}"
    _local_path="/home/igor/_${1}"
    if printf '%s\n' "${_debug_data}" | grep -F -A3 "${_remote_path}" | grep -q 'DISCONNECTED'
    then
        _log "${_remote_path} is DISCONNECTED (${_ping_http_code})"
        if [ "${_ping_http_code}" = "200" ]
        then
            umount -c -v "${_local_path}" 2>&1 | _log
            "${_root}/mount.sh" "${1}" 2>&1 | _log
        fi
    fi
}

_check_mount 'private'
_check_mount 'public'

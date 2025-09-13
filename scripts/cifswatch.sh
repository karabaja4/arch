#!/bin/sh
. "$(dirname "$(readlink -f "${0}")")/_lib.sh"

# CIFS is unable to re-establish connection on SMB server restart when using a custom port
# DebugData shows DISCONNECTED:

# 1) \\radiance.hr\public
# ...
# ...	DISCONNECTED

_must_be_root

_root="$(dirname "$(readlink -f "${0}")")"
_debug_data="$(cat /proc/fs/cifs/DebugData)"

_check_mount() {
    _remote_path="\\\\radiance.hr\\${1}"
    _local_path="/home/igor/_${1}"
    if printf '%s\n' "${_debug_data}" | grep -F -A3 "${_remote_path}" | grep -q 'DISCONNECTED'
    then
        printf 'Detected %s as DISCONNECTED, remounting...\n' "${_remote_path}"
        # use -c to not canonicalize paths
        # otherwise umount stalls on a non-responsive path
        # as does mountpoint -q, so don't use umount.sh
        umount -c -v "${_local_path}"
        "${_root}/mount.sh" "${1}"
    fi
}

_check_mount 'private'
_check_mount 'public'

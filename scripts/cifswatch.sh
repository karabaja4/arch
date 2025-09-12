#!/bin/sh

# CIFS is unable to re-establish connection on SMB server restart when using a custom port
# DebugData shows DISCONNECTED:

# 1) \\radiance.hr\public
# ...
# ...	DISCONNECTED

_root="$(dirname "$(readlink -f "${0}")")"
_debug_data="$(cat /proc/fs/cifs/DebugData)"

# ${1} = remote path
# ${2} = port
# ${3} = local path
_check_mount() {
    if printf '%s\n' "${_debug_data}" | grep -F -A3 "${1}" | grep -q 'DISCONNECTED'
    then
        # use -c to not canonicalize paths
        # otherwise umount stalls on a non-responsive path
        printf 'Detected %s as DISCONNECTED, remounting...\n' "${1}"
        doas umount -c -v "${3}"
        doas "${_root}/smb.sh" "${1}" "${2}" "${3}"
    fi
}

_check_mount '\\radiance.hr\private' '44555' '/home/igor/_private'
_check_mount '\\radiance.hr\public' '44555' '/home/igor/_public'

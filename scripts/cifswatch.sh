#!/bin/sh

# CIFS is unable to re-establish connection on SMB server restart when using a custom port
# DebugData shows DISCONNECTED:

# 1) \\radiance.hr\public
# ...
# ...	DISCONNECTED

_root="$(dirname "$(readlink -f "${0}")")"
_debug_data="$(cat /proc/fs/cifs/DebugData)"

# ${1} = port
# ${2} = remote path
# ${3} = local path
_check_mount() {
    if printf '%s\n' "${_debug_data}" | grep -F -A3 "${2}" | grep -q 'DISCONNECTED'
    then
        # use -c to not canonicalize paths
        # otherwise umount stalls on a non-responsive path
        printf 'Detected %s as DISCONNECTED, remounting...\n' "${2}"
        doas umount -c -v "${3}"
        doas "${_root}/smb.sh" "${@}"
    fi
}

_check_mount '44555' '\\radiance.hr\private' '/home/igor/_private'
_check_mount '44555' '\\radiance.hr\public' '/home/igor/_public'

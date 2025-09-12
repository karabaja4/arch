#!/bin/sh

# CIFS is unable to re-establish connection on SMB server restart
# DebugData shows DISCONNECTED:

# 1) \\radiance.hr\public Mounts: 1 DevInfo: 0x20 Attributes: 0x1006f
# PathComponentMax: 255 Status: 3 type: DISK Serial Number: 0x1ef82e91
# Share Capabilities: None Aligned, Partition Aligned,	Share Flags: 0x0
# tid: 0xe63316b7	Optimal sector size: 0x200	Maximal Access: 0x1f01ff	DISCONNECTED

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

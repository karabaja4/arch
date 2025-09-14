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
    # cifs not loaded
    exit 0
fi

_debug_data="$(cat "${_debug_data_path}")"
_host="radiance.hr"

_check_mount() {
    _remote_path="\\\\${_host}\\${1}"
    if printf '%s\n' "${_debug_data}" | grep -F -A3 "${_remote_path}" | grep -q 'DISCONNECTED'
    then
        _log "${_remote_path} is DISCONNECTED"
    
        _nc_out="$(nc -z -w2 "${_host}" 44555 2>&1)"
        _nc_ec="${?}"
        _log "${_nc_out}"
        _log "nc exited with ${_nc_ec}"
        if [ "${_nc_ec}" -eq 0 ]
        then
            # smb working
            _local_path="/home/igor/_${1}"
            _log "Remounting ${_local_path}"
            
            # umount
            _umount_out="$(umount -c -v "${_local_path}" 2>&1)"
            _umount_ec="${?}"
            _log "${_umount_out}"
            _log "umount exited with ${_umount_ec}"
            
            # if umount ok
            if [ "${_umount_ec}" -eq 0 ]
            then
            
                #mount
                _mount_out="$("${_root}/mount.sh" "${1}" 2>&1)"
                _mount_ec="${?}"
                _log "${_mount_out}"
                _log "mount exited with ${_mount_ec}"
                
                # success
                if [ "${_mount_ec}" -eq 0 ]
                then
                    _log 'All good.'
                fi
            fi
        fi
    fi
}

_check_mount 'private'
_check_mount 'public'

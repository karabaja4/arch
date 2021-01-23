#!/bin/bash

_mount() {
    local -r _user="$(who | awk '{print $1}')"
    local -r _dir="/mnt/$(basename "${1}")"
    local -r _uid="$(id -u "${_user}")"
    local -r _gid="$(id -g "${_user}")"
    install -m 755 -g "${_user}" -o "${_user}" -d "${_dir}"
    mount -o uid="${_uid}",gid="${_gid}" "${1}" "${_dir}"
}

_enum() {
    local -a _partitions=()
    mapfile -t _partitions <<< "$(lsblk -o name -lnp "${1}")"
    for part in "${_partitions[@]}"
    do
        if [[ "${part}" != "${1}" ]]
        then
            _mount "${part}"
        fi
    done
}

( _enum "${1}" ) &
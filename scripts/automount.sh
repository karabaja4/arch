#!/bin/bash
set -uo pipefail

_usage() {
    echo "This is script is called by /etc/udev/rules.d/10-flash.rules"
    exit 2
}

(( ${#} == 0 )) && _usage

_mount() {
    local -r _user="$(id -un 1000)"
    local -r _dir="/mnt/$(basename "${1}")"
    local -ir _uid="$(id -u "${_user}")"
    local -ir _gid="$(id -g "${_user}")"
    install -m 755 -g "${_user}" -o "${_user}" -d "${_dir}"
    mount -o uid="${_uid}",gid="${_gid}" "${1}" "${_dir}"
}

_enum() {
    local -a _partitions=()
    mapfile -t _partitions < <(lsblk -o name -lnp "${1}")
    for part in "${_partitions[@]}"
    do
        if [[ "${part}" != "${1}" ]]
        then
            _mount "${part}"
        fi
    done
}

( _enum "${1}" & )
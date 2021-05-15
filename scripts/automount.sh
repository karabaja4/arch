#!/bin/bash
# shellcheck disable=SC2034

set -uo pipefail

_mapfile() {
    local -n _ref=${1}
    if [[ -n "${2}" ]]
    then
        mapfile -t _ref <<< "${2}"
    fi
}

_mount() {
    local -r _user="$(who | awk 'NR==1{print $1}')"
    local -r _dir="/mnt/$(basename "${1}")"
    local -ir _uid="$(id -u "${_user}")"
    local -ir _gid="$(id -g "${_user}")"
    install -m 755 -g "${_user}" -o "${_user}" -d "${_dir}"
    mount -o uid="${_uid}",gid="${_gid}" "${1}" "${_dir}"
}

_enum() {
    local -a _partitions=()
    _mapfile _partitions "$(lsblk -o name -lnp "${1}")"
    for part in "${_partitions[@]}"
    do
        if [[ "${part}" != "${1}" ]]
        then
            _mount "${part}"
        fi
    done
}

( _enum "${1}" & )
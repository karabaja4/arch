#!/bin/bash

declare -a _partitions=()
mapfile -t _partitions <<< "$(lsblk -o name -lnp "${1}")"

_mount() {
    local -r dir="/home/igor/_flash/$(basename "${1}")"
    install -m 755 -g igor -o igor -d "${dir}"
    mount -o uid=1000,gid=1000 "${1}" "${dir}"
}

for part in "${_partitions[@]}"
do
    if [[ "${part}" != "${1}" ]]
    then
        _mount "${part}"
    fi
done
#!/bin/bash
set -uo pipefail

_usage() {
    echo "This is script is called by /etc/udev/rules.d/10-flash.rules"
    exit 2
}

_not_root() {
    echo "Root privileges are required to run this command"
    exit 1
}

(( ${#} == 0 )) && _usage
(( EUID != 0 )) && _not_root

declare -ir _id=1000

_mount() {
    local -r _user="$(id -un ${_id})"
    local -r _dir="/mnt/${1}"
    local -ir _uid="$(id -u "${_user}")"
    local -ir _gid="$(id -g "${_user}")"
    install -m 0755 -g "${_user}" -o "${_user}" -d "${_dir}"
    mount -o uid="${_uid}",gid="${_gid}" "/dev/${1}" "${_dir}"
}

_enum() {
    local -a _partitions=()
    mapfile -t _partitions < <(lsblk -J "${1}" | jq -crM '.blockdevices[] | .children[] | select(.type=="part") | .name')
    for part in "${_partitions[@]}"
    do
        _mount "${part}"
    done
}

( _enum "${1}" & )
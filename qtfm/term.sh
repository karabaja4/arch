#!/bin/bash
set -euo pipefail

_temp="$(printf '%s\n' "${@}")"
export _temp

_exec() {

    [ -z "${_temp}" ] && exit 1
    local -a _params
    mapfile -t _params <<< "${_temp}"

    for i in "${!_params[@]}"
    do 
        printf '\033[32m%s\033[0m\n' "${i}: ${_params[${i}]}"
    done

    case "${_params[0]}" in
    rm)
        rm -vrf "${_params[@]:1}"
        ;;
    extract)
        tar xvf "${_params[1]}"
        ;;
    unzip)
        unzip -o "${_params[1]}"
        ;;
    unrar)
        unrar x "${_params[1]}"
        ;;
    7z)
        7z x "${_params[1]}"
        ;;
    gzip)
        tar cvzf "${_params[1]}.tar.gz" "${_params[@]:2}"
        ;;
    zip)
        zip -vr "${_params[1]}.zip" "${_params[@]:2}"
        ;;
    unmount)
        sudo umount -v /mnt/igor/* || echo "umount failed"
        rm -vrf /mnt/igor/* || echo "rm failed"
        ;;
    esac

    exec bash
}

export -f _exec
xfce4-terminal -x bash -c _exec


#!/bin/bash

_temp="$(printf '%s\n' "${@}")"
export _temp

_exec() {

    [ -z "${_temp}" ] && exit 1
    local -a _params
    mapfile -t _params <<< "${_temp}"
    set -- "${_params[@]}"

    local -i _idx=0
    for p in "${_params[@]}"
    do
        printf '\033[32m%s\033[0m\n' "$(( ++_idx )): ${p}"
    done

    case "${1}" in
    rm)
        rm -vrf "${@:2}"
        ;;
    extract)
        tar xvf "${2}"
        ;;
    unzip)
        unzip -o "${2}"
        ;;
    unrar)
        unrar x "${2}"
        ;;
    gzip)
        tar cvzf "${2}.tar.gz" "${@:3}"
        ;;
    zip)
        zip -r "${2}.zip" "${@:3}"
        ;;
    unmount)
        sudo umount -v /mnt/* || echo "umount failed"
        sudo rm -vrf /mnt/* || echo "rm failed"
        ;;
    esac

    exec bash
}

export -f _exec
xfce4-terminal -x bash -c _exec


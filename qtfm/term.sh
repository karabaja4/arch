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
    7z)
        7z x "${_params[1]}"
        ;;
    gzip)
        tar cvzf "${_params[1]}.tar.gz" "${_params[@]:2}"
        ;;
    zip)
        7z a -tzip "${_params[1]}.zip" "${_params[@]:2}"
        ;;
    copyhere|movehere)
        if [ -f "/tmp/qtfm.paths" ]
        then
            while IFS= read -r _line
            do
                if [ "${_params[0]}" = "copyhere" ]
                then
                    cp -v -r "${_line}" "${PWD}"
                else
                    mv -v "${_line}" "${PWD}"
                fi
                
            done < "/tmp/qtfm.paths"
        fi
        ;;
    esac

    exec bash
}

export -f _exec
xfce4-terminal -x bash -c _exec


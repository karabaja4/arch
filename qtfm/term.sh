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
        printf '\033[31m%s\033[0m\n' "${i}: ${_params[${i}]}"
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
    paste)
        local _paths="/tmp/qtfm.paths"
        if [ -f "${_paths}" ]
        then
            _action="$(head -n1 ${_paths})"
            while IFS= read -r -u9 _line
            do
                if [ "${_action}" = "cut" ]
                then
                    mv -v -i "${_line}" "${PWD}"
                elif [ "${_action}" = "copy" ]
                then
                    cp -v -r -i "${_line}" "${PWD}"
                fi
            done 9< <(sed 1d "${_paths}")
        fi
        ;;
    esac

    exec bash
}

export -f _exec
xfce4-terminal -x bash -c _exec

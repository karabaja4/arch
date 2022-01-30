#!/bin/bash
# shellcheck disable=SC2016
set -euo pipefail

_exec() {

    local _i=1
    for _arg in "${@}"
    do
        printf '\033[31m%s: [ %s ]\033[0m\n' "${_i}" "${_arg}"
        _i=$((_i + 1))
    done

    case "${1}" in
    rm)
        rm -vrf "${@:2}"
        ;;
    extract)
        tar xvf "${2}"
        ;;
    7z)
        7z x "${2}"
        ;;
    gzip)
        tar cvzf "${2}.tar.gz" "${@:3}"
        ;;
    zip)
        7z a -tzip "${2}.zip" "${@:3}"
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

    printf '\033[32mExited.\033[0m\n'
    exec bash
}
export -f _exec

case "${1}" in
cut|copy)
    printf '%s\n%s\n' "${1}" "${@:2}" | grep -v '^\s*$' > /tmp/qtfm.paths
    ;;
copypath)
    printf '%s' "${2}" | xclip -i -selection clipboard
    ;;
openterm)
    xfce4-terminal --working-directory="${PWD}"
    ;;
vscode)
    code --folder-uri "${PWD}"
    ;;
*)
    xfce4-terminal -x bash -c '_exec "${@}"' _ "${@}"
esac

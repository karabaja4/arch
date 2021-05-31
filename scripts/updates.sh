#!/bin/bash
set -uo pipefail

_write() {
    local filepath="/tmp/update_count"
    echo "${1}" > "${filepath}"
    chmod 666 "${filepath}"
    echo "write: ${1} updates"
}

_run() {
    local _cu
    local _aur
    local -i _cuec
    local -i _aurec
    local -i _ec=0
    while true
    do
        _cu="$(checkupdates)"
        _cuec=${?}
        echo "checkupdates exited with ${_cuec}"

        _aur="$(auracle outdated)"
        _aurec=${?}
        echo "auracle exited with ${_aurec}"

        if (( (_cuec == 0 || _cuec == 2) && (_aurec == 0 || _aurec == 1) ))
        then
            echo "success"
            local -a _cupkgs=()
            if [[ -n "${_cu}" ]]
            then
                mapfile -t _cupkgs <<< "${_cu}"
            fi
            local -a _aurpkgs=()
            if [[ -n "${_aur}" ]]
            then
                mapfile -t _aurpkgs <<< "${_aur}"
            fi
            _write "${#_cupkgs[@]} (${#_aurpkgs[@]})"
            break
        else
            echo "failure"
            if (( ++_ec >= 100 ))
            then
                echo "giving up (${_ec})"
                break
            else
                echo "retrying (${_ec})"
                sleep 1
            fi
        fi
    done
}

_run
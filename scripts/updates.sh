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
    local -i _rv
    local -i _ec=0
    while true
    do
        _cu="$(checkupdates)"
        _rv=${?}
        echo "checkupdates exited with ${_rv}"
        if (( _rv == 0 || _rv == 2 ))
        then
            if [[ -n "${_cu}" ]]
            then
                local -a _upd=()
                mapfile -t _upd <<< "${_cu}"
                _write "${#_upd[@]}"
            else
                _write "0"
            fi
            break
        else
            if (( ++_ec >= 100 ))
            then
                echo "giving up (${_ec})"
                break
            else
                _write "-"
                echo "retrying (${_ec})"
                sleep 1
            fi
        fi
    done
}

_run
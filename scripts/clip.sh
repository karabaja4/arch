#!/bin/bash
set -uo pipefail

# TARGETS configuration
declare -ar _pref=(
    "image/png"
    "text/uri-list"
    "code/file-list"
)

_usage() {
    echo "Invalid arguments."
    exit 1
}

(( ${#} > 0 )) && _usage

_log() {
    echo -e "\033[32m->\033[0m" "${@}"
}

_iteration() {
    local -r _utf8="UTF8_STRING"

    # target test of current selection
    local _tc
    _tc="$(xclip -selection clipboard -o -t TARGETS)"
    local -ir _tcec=${?}
    _log "TARGETS check exited with: ${_tcec}"

    if (( _tcec != 0 ))
    then
        # on empty wait for any selection
        _log "Waiting on initial selection with: ${_utf8}"
        xclip -verbose -in -selection clipboard -t "${_utf8}" < /dev/null
    else
        local -a _targets=()
        if [[ -n "${_tc}" ]]
        then
            mapfile -t _targets <<< "${_tc}"
        fi
        _log "Clipboard targets (${#_targets[@]}): ${_targets[*]}"
        _log "Preferred targets (${#_pref[@]}): ${_pref[*]}"
        _log "Default targets: ${_utf8}"

        # join both lists together, and print first item of targets occuring in _pref
        local -r _match="$(printf '%s\n' "${_targets[@]}" "${_pref[@]}" "${_utf8}" | awk 'a[$0]++' | head -n1)"

        if [[ -n "${_match}" ]]
        then
            _log "Matched target: ${_match}"
            xclip -verbose -out -selection clipboard -t "${_match}" | xclip -verbose -in -selection clipboard -t "${_match}"
        else
            _log "Unable to match targets"
            sleep 1
        fi
    fi
}

while true
do
    _log "--------------------"
    _iteration
done

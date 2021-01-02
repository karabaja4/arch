#!/bin/bash
set -uo pipefail

# TARGETS configuration
declare -ar _pref=(
    "image/png"
    "text/uri-list"
    "code/file-list"
)

_usage() {
    echo "Usage:"
    echo "  ./$(basename "${0}")"
    echo "Configuration:"
    echo "  Add your preferred TARGETS to the '_pref' array in the script to handle custom formats."
    echo "  Current _pref:"
    printf -- '  - %s\n' "${_pref[@]}"
    exit 1
}

(( ${#} > 0 )) && _usage

_log() {
    echo -e "\033[32m->\033[0m" "${@}"
}

_iteration() {
    declare -r _utf8="UTF8_STRING"

    # target test of current selection
    declare _ttres
    _ttres="$(xclip -selection clipboard -o -t TARGETS)"
    declare -ir _ttec=${?}
    _log "TARGETS check exited with: ${_ttec}"
    declare -a _targets
    mapfile -t _targets <<< "${_ttres}"

    if (( _ttec != 0 || ${#_targets[@]} == 0 ))
    then
        # on empty wait for any selection
        _log "Waiting on initial selection with: ${_utf8}"
        xclip -verbose -in -selection clipboard -t "${_utf8}" < /dev/null
    else
        _log "Preferred targets: ${_pref[*]}"
        _log "Clipboard targets: ${_targets[*]}"

        # join both lists together, and print first item of targets occuring in _pref
        declare _match
        _match="$(printf '%s\n' "${_targets[@]}" "${_pref[@]}" "${_utf8}" | awk 'a[$0]++' | head -n1)"

        if [[ -n ${_match} ]]
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
    _log "$(head -c 80 /dev/zero | tr '\0' '-')"
    _iteration
done

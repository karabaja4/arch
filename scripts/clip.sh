#!/bin/bash
set -uo pipefail

# TARGETS configuration
declare -ar preferred_targets=(
    "image/png"
    "text/uri-list"
    "code/file-list"
)

_usage() {
    echo "Usage:"
    echo "  ./$(basename "${0}")"
    echo "Configuration:"
    echo "  Add your preferred TARGETS to the 'preferred_targets' array in the script to handle custom formats."
    echo "  Current preferred_targets:"
    printf -- '  - %s\n' "${preferred_targets[@]}"
    exit 1
}

(( ${#} > 0 )) && _usage

_log() {
    echo -e "\033[32m->\033[0m" "${@}"
}

# main
declare -r default_target="UTF8_STRING"

_iteration() {

    # test targets of current selection
    declare tt
    tt="$(xclip -selection clipboard -o -t TARGETS)"
    declare -ir ec=${?}
    _log "TARGETS check exited with ${ec}"
    mapfile -t targets <<< "${tt}"

    if (( ${ec} != 0 || ${#targets[@]} == 0 ))
    then
        # on empty wait for any selection
        _log "Waiting on initial selection with: ${default_target}"
        xclip -verbose -in -selection clipboard -t "${default_target}" < /dev/null
    else
        _log "Preferred targets: ${preferred_targets[*]}"
        _log "Clipboard targets: ${targets[*]}"

        # join both lists together, and print first item of targets occuring in preferred_targets
        declare -r target="$(printf '%s\n' "${targets[@]}" "${preferred_targets[@]}" "${default_target}" | awk 'a[$0]++' | head -n1)"

        if [[ -n ${target} ]]
        then
            _log "Chosen target: ${target}"
            xclip -verbose -out -selection clipboard -t "${target}" | xclip -verbose -in -selection clipboard -t "${target}"
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

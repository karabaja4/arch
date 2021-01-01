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

# main
declare -r default_target="UTF8_STRING"

_iteration() {
    echo "-> ------------------------------------------------------------------------------"
    declare -ar targets=( $(xclip -selection clipboard -o -t TARGETS) )
    if (( ${?} != 0 || ${#targets[@]} == 0 ))
    then
        echo "-> Initializing using: ${default_target}"
        echo -n "" | xclip -verbose -in -selection clipboard -t "${default_target}"
    else
        echo "-> Preferred targets: ${preferred_targets[@]}"
        echo "-> Clipboard targets: ${targets[@]}"

        # join both lists together, and print first item of targets occuring in preferred_targets
        declare -r target="$(printf '%s\n' "${targets[@]}" "${preferred_targets[@]}" "${default_target}" | awk 'a[$0]++' | head -n1)"

        if [[ -n ${target} ]]
        then
            echo "-> Chosen target: ${target}"
            xclip -verbose -out -selection clipboard -t "${target}" | xclip -verbose -in -selection clipboard -t "${target}"
        else
            echo "-> Unable to match targets"
            sleep 1
        fi
    fi
}

while true
do
    _iteration
done

#!/bin/bash
set -uo pipefail

# TARGETS configuration
declare -a preferred_targets=("image/png" "text/uri-list" "code/file-list")

usage() {
    echo "Usage:"
    echo "  ./$(basename "${0}")"
    echo "Configuration:"
    echo "  Add your preferred TARGETS to the 'preferred_targets' array in the script to handle custom formats."
    echo "  Current preferred_targets:"
    printf -- '  - %s\n' "${preferred_targets[@]}"
    exit 1
}

(( ${#} > 0 )) && usage

# default
preferred_targets+=("UTF8_STRING")

while true
do
    echo "-> $(head -c 78 /dev/zero | tr '\0' '-')"
    targets=( $(xclip -selection clipboard -o -t TARGETS) )
    if (( ${?} != 0 || ${#targets[@]} == 0 ))
    then
        echo "-> ERROR: failed to fetch targets"
        sleep 1
    else
        echo "-> Preferred targets: ${preferred_targets[@]}"
        echo "-> Clipboard targets: ${targets[@]}"

        # join both lists together, and print first item of targets occuring in preferred_targets
        target="$(echo ${targets[@]} ${preferred_targets[@]} | tr ' ' '\n' | awk 'a[$0]++' | head -n1)"

        if [[ -n ${target} ]]
        then
            echo "-> Chosen target: ${target}"
            xclip -verbose -out -selection clipboard -t "${target}" | xclip -verbose -in -selection clipboard -t "${target}"
        else
            echo "-> ERROR: unable to match targets"
            sleep 1
        fi
    fi

done

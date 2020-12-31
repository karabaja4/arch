#!/bin/bash
set -uo pipefail

# TARGETS configuration
declare -ar preferred_targets=(
    "image/png"
    "text/uri-list"
    "code/file-list"
    "text/plain"
    "UTF8_STRING"
)

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

while true
do
    echo "-> $(head -c 78 /dev/zero | tr '\0' '-')"
    targets=( $(xclip -selection clipboard -o -t TARGETS) )

    echo "-> Preferred targets: ${preferred_targets[@]}"
    echo "-> Clipboard targets: ${targets[@]}"

    # join both lists together, and print first item of targets occuring in preferred_targets
    target="$(echo ${targets[@]} ${preferred_targets[@]} | tr ' ' '\n' | awk 'a[$0]++' | head -n1)"
    echo "-> Target: ${target:-"UTF8_STRING (default)"}"

    xclip -verbose -out -selection clipboard -t "${target:-"UTF8_STRING"}" | xclip -verbose -in -selection clipboard -t "${target:-"UTF8_STRING"}"
done

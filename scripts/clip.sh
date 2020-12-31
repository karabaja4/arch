#!/bin/bash
set -uo pipefail

echo -e "[$(basename "${0}") - xclip based clipboard manager for XA_CLIPBOARD]"

usage() {
    echo -e "-> Please define your preferred targets in the 'preferred_targets' array to handle custom formats"
    exit 1
}

(( ${#} > 0 )) && usage

declare -ar preferred_targets=(
    "image/png"
    "text/uri-list"
    "code/file-list"
    "text/plain"
)

while true
do
    echo "-> $(head -c 78 /dev/zero | tr '\0' '-')"
    targets=( $(xclip -selection clipboard -o -t TARGETS) )

    echo "-> Preferred targets: ${preferred_targets[@]}"
    echo "-> Clipboard targets: ${targets[@]}"

    # prints both lists together, and prints intersection sorted by first occurance of type in preferred_targets
    target="$(echo ${targets[@]} ${preferred_targets[@]} | tr ' ' '\n' | awk 'a[$0]++' | head -n1)"
    echo "-> Target: ${target:-"text/plain (default)"}"

    xclip -verbose -out -selection clipboard -t "${target:-"text/plain"}" | xclip -verbose -in -selection clipboard -t "${target:-"text/plain"}"
done

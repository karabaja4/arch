#!/bin/bash
set -euo pipefail

# sudo mv /usr/bin/xdg-open /usr/bin/xdg-open.bak
# sudo ln -sf /home/igor/arch/mime2/mime2.sh /usr/bin/xdg-open

usage() {
    echo "usage: ${0} [file | URL]"
    exit 2
}

[ ${#} -eq 0 ] && usage

declare -r logs="$HOME/.local/share/mime2"
mkdir -p "$logs"

declare -r dir="$(dirname "$(readlink -f "${0}")")"
# declare -r result="$(node "${dir}/main.js" "${1}")"
# if [ -z "$result" ]
# then
#     echo "mime2: Unable to open ${1}" >> "$logs/log"
# else
#     echo "mime2: ${1} -> ${result}" >> "$logs/log"
#     readarray -t -d '' arr < <(xargs printf "%s\0" <<< "$result")
#     "${arr[@]}"
# fi
node "${dir}/main.js" "${1}"
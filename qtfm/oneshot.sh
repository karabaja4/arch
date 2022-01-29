#!/bin/bash
set -euo pipefail

case "${1}" in
cut|copy)
    printf '%s\n%s\n' "${1}" "${@:2}" | grep -v '^\s*$' > /tmp/qtfm.paths
    ;;
copypath)
    echo -n "${2}" | xclip -i -selection clipboard
    ;;
openterm)
    xfce4-terminal --working-directory="${PWD}"
    ;;
vscode)
    code --folder-uri "${PWD}"
    ;;
esac

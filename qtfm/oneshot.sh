#!/bin/bash
set -euo pipefail

case "${1}" in
selectcopy)
    printf '%s\n' "${@:2}" > /tmp/qtfm.paths
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

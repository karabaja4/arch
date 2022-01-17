#!/bin/bash
set -euo pipefail

case "${1}" in
copypath)
    printf '%s\n' "${@:2}" > /tmp/qtfm.paths
    ;;
openterm)
    xfce4-terminal --working-directory="${PWD}"
    ;;
vscode)
    code --folder-uri "${PWD}"
    ;;
esac

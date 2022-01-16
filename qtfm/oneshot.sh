#!/bin/bash
set -euo pipefail

case "${1}" in
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

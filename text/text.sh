#!/bin/bash
set -euo pipefail

if [ $# -eq 0 ]
then
    mkdir -p "${HOME}/.text"
    declare -r temp="$(date -u +"%Y-%m-%dT%H-%M-%SZ")"
    declare -r filename="${HOME}/.text/${temp}.js"
    touch "${filename}"
    echo "Opening ${filename}"
    featherpad "${filename}"
    if [ ! -s "${filename}" ]
    then
        rm "${filename}"
    fi
else
    echo "Opening ${1}"
    featherpad "${1}"
fi
#!/bin/bash
set -euo pipefail

if [ $# -eq 0 ]
then
    mkdir -p "${HOME}/.text"
    declare -r temp="$(date -u +"%Y-%m-%dT%H-%M-%SZ")"
    declare -r filename="${HOME}/.text/${temp}.js"
    featherpad "${filename}" &> /dev/null &
else
    featherpad "${1}" &> /dev/null &
fi
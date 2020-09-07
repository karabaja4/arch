#!/bin/bash
set -euo pipefail

mkdir -p "${HOME}/.text"
declare filename=""
declare temp=""

if [ $# -eq 0 ]
then
    temp=$(date -u +"%Y-%m-%dT%H-%M-%SZ")
    filename="${HOME}/.text/${temp}.js"
else
    filename="${1}"
fi

echo "Opening ${filename}"
touch "${filename}"
featherpad "${filename}"
if [ ! -s "${filename}" ]
then
    rm "${filename}"
fi
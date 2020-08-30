#!/bin/bash
set -euo pipefail

mkdir -p "$HOME/.geany"
declare filename
declare temp

if [ $# -eq 0 ]
then
    temp=$(date -u +"%Y-%m-%dT%H-%M-%SZ")
    filename="$HOME/.geany/$temp.js"
else
    filename="$1"
fi

echo "Opening $filename"
geany -i -m -n -p -s -t "$filename"
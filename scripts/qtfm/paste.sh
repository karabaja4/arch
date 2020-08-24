#!/bin/bash
set -euo pipefail

declare action=$(cat /tmp/qtfm/action)

while IFS= read -r line; do
    "$action" "$line" "$1" | zenity --progress --pulsate --no-cancel --auto-close --text="$action $line to $1"
done < /tmp/qtfm/paths

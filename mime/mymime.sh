#!/bin/bash
set -euo pipefail

declare extension=""
declare path="$1"
declare filename=$(basename "$path")

echo "Opening: $path"
echo "Base file name: $filename"

if [[ ${filename:0:1} == "." ]]; then
    echo "Dotfile detected, not using extensions"
elif [[ $filename != *"."* ]]; then
    echo "Filename does not contain a dot, not using extensions"
else
    extension="${filename##*.}"
    echo "Found extension: $extension"
fi

case "$extension" in
    pdf)
        mupdf -r 96 "$path";;
    jpg|jpeg|svg|png|bmp)
        gpicview "$path";;
    avi|mkv|flac|mp3|wav|mp4)
        vlc "$path";;
    txt|c|js|conf|md|sh|json|map|yml|xml|py|log)
        geany -i -m -n -p -s -t "$path";;
    torrent)
        qbittorrent "$path";;
    html|htm)
        chromium "$path";;
    *)
        echo "Using xdg-mime to query filetype for file $path"
        mime=$(xdg-mime query filetype "$path")
        case "$mime" in
            text/plain)
                geany -i -m -n -p -s -t "$path";;
            inode/directory)
                qtfm "$path";;
            *)
                zenity --info --text="Missing definition for $extension as $mime" --no-wrap;;
        esac
        ;;
esac
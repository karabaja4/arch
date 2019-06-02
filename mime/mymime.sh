#!/bin/bash

path="$1"
extension="${path##*.}"

case "$extension" in
    pdf)
        mupdf -r 96 "$path";;
    jpg|jpeg|svg|png|bmp)
        gpicview "$path";;
    avi|mkv|flac|mp3|wav)
        vlc "$path";;
    txt|c|js|conf|md|sh|json|map|yml)
        geany -i -m -n -p -s -t "$path";;
    *)
        mime=$(xdg-mime query filetype $path)
        case "$mime" in
            text/plain)
                geany -i -m -n -p -s -t "$path";;
            *)
                zenity --info --text="Missing definition for $extension as $mime" --no-wrap;;
        esac
        ;;
esac
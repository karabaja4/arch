#!/bin/bash

path="$1"
extension="${path##*.}"

case "$extension" in
    pdf)
        mupdf "$path";;
    jpg|svg|png)
        gpicview "$path";;
    avi|mkv|flac|mp3|wav)
        vlc "$path";;
    txt|c|js|conf|md|sh|json|map)
        geany -i -m -n -p -s -t "$path";;
    *)
        zenity --info --text="No extension was defined for $extension" --no-wrap;;
esac
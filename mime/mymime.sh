#!/bin/bash
set -euo pipefail

declare extension=""
declare path="${1}"
declare filename="$(basename "${path}")"

# if not a dotfile and contains a dot, get the extension
if [[ ${filename:0:1} != "." ]] && [[ ${filename} == *"."* ]]
then
    extension="${filename##*.}"
fi

case "${extension,,}" in
    pdf)
        mupdf -r 96 "${path}";;
    jpg|jpeg|svg|png|bmp|gif|tga)
        gpicview "${path}";;
    avi|mkv|flac|mp3|wav|mp4)
        vlc "${path}";;
    txt|c|cpp|js|conf|md|sh|json|map|yml|xml|py|log|cs|ini)
        featherpad "${path}";;
    torrent)
        qbittorrent "${path}";;
    html|htm)
        chromium "${path}";;
    gz|zip|rar|zst)
        xarchiver "${path}";;
    *)
        mime=$(file --brief --mime-type "${path}")
        case "${mime}" in
            text/*)
                featherpad "${path}";;
            inode/directory)
                qtfm "${path}";;
            *)
                zenity --info --text="Missing definition for ${extension} as ${mime}" --no-wrap;;
        esac
        ;;
esac
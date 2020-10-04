#!/bin/bash
set -euo pipefail

# sudo mv /usr/bin/xdg-open /usr/bin/xdg-open.bak
# sudo ln -s /home/igor/arch/mime/mymime.sh /usr/bin/xdg-open

usage() {
    echo "usage: ${0} [file | URL]"
    exit 2
}

[ ${#} -eq 0 ] && usage

error() {
    zenity --error --no-wrap --text="${1}"
    exit 1
}

declare -r rgx="^[a-z]+://.+$"

# protocol mode
if [[ ${1} =~ ${rgx} ]]
then
    declare -r uri="${1}"
    declare -r protocol="$(echo "${uri}" | grep -oP ".+?(?=://)")"
    case "${protocol}" in
    slack)
        slack "${uri}";;
    http|https)
        chromium "${uri}";;
    file)
        qtfm "$(dirname "${uri}")";;
    *)
        error "No protocol defined for ${protocol} (${uri})";;
    esac
    exit 0
fi

# file mode
declare path="${1}"
if [[ ${path} == "." ]]
then
    path="${PWD}"
fi

declare -r fname="$(basename "${path}")"
declare ext=""

# if not a dotfile and contains a dot, get the extension
if [[ ${fname:0:1} != "." ]] && [[ ${fname} == *"."* ]]
then
    ext="${fname##*.}"
fi

case "${ext,,}" in
    pdf)
        mupdf -r 96 "${path}";;
    jpg|jpeg|svg|png|bmp|gif|tga)
        gpicview "${path}";;
    avi|mkv|flac|mp3|wav|mp4|mov)
        vlc "${path}";;
    txt|c|cpp|js|conf|md|sh|json|map|yml|xml|py|log|cs|ini|csv)
        featherpad "${path}";;
    torrent)
        qbittorrent "${path}";;
    gz|zip|rar|zst)
        xarchiver "${path}";;
    *)
        if [ ! -e "${path}" ]
        then
            error "Not a file or directory: ${path}"
        fi
        declare mime="$(file --brief --mime-type "${path}")"
        case "${mime}" in
            inode/x-empty|application/octet-stream|text/*)
                featherpad "${path}";;
            inode/directory)
                qtfm "${path}";;
            *)
                error "Missing definition for ${ext} as ${mime}";;
        esac
        ;;
esac
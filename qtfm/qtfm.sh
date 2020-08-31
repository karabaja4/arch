#!/bin/bash
#set -euo pipefail

declare -r action_path="/tmp/qtfm/action"
declare -r files_path="/tmp/qtfm/files"

spin() {
    zenity --progress --pulsate --no-cancel --auto-close --text="$1"
}

case "$1" in
cut)
    echo -n "mv" > "$action_path"
    printf "%s\n" "${@:2}" > "$files_path"
    ;;
copy)
    echo -n "cp -r" > "$action_path"
    printf "%s\n" "${@:2}" > "$files_path"
    ;;
paste)
    if [ ! -f "$action_path" ] || [ ! -f "$files_path" ]
    then
        exit 1
    fi
    declare -r action="$(cat "$action_path")"
    while IFS= read -r line
    do
        if [ ! -e "$line" ] # check if source exists
        then
            zenity --error --no-wrap --text="$line does not exist"
        else
            declare dest="$2/$(basename "$line")"
            if [ -e "$dest" ] # check if dest exists
            then
                declare suffix="$(ls "$dest"* | wc -l)"
                dest="${dest}_${suffix}"
            fi
            declare cmd=($action)
            "${cmd[@]}" "$line" "$dest" | spin "$action $line to $dest"
        fi
    done < "$files_path"
    ;;
rm)
    rm -rf "${@:2}";;
copypath)
    echo -n "$2" | xclip -i -selection clipboard;;
extract)
    tar xvf "$2" | spin "extracting $2";;
term)
    xfce4-terminal --working-directory="$2";;
feh)
    feh --bg-scale "$2";;
thumb)
    convert -resize 13% "$2" "thumb_$2";;
unzip)
    unzip "$2" | spin "extracting $2";;
unrar)
    unrar x "$2" | spin "extracting $2";;
gzip)
    tar cvzf "$2.tar.gz" "${@:3}" | spin "creating archive $2.tar.gz";;
copyurl)
    declare -r path="$(realpath --relative-to="/home/igor/_azure" "$2")"
    declare -r url="https://igorsaric.file.core.windows.net/storage1/$path"
    declare -r full="${url}$(cat "/home/igor/arch/qtfm/sas.token")"
    echo "$full" | xclip -i -selection clipboard
    ;;
esac

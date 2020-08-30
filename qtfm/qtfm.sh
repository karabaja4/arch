#!/bin/bash
#set -euo pipefail

declare -r action_path="/tmp/qtfm/action"
declare -r files_path="/tmp/qtfm/files"

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
            declare dest="$2/$(basename $line)"
            if [ -e "$dest" ] # check if dest exists
            then
                declare suffix="$(ls ${dest}* | wc -l)"
                dest="${dest}_${suffix}"
            fi
            declare cmd=($action)
            "${cmd[@]}" "$line" "$dest" | zenity --progress --pulsate --no-cancel --auto-close --text="$action $line to $dest"
        fi
    done < "$files_path"
    ;;
rm)
    rm -rf "${@:2}"
    ;;
copypath)
    echo -n "$2" | xclip -i -selection clipboard
    ;;
extract)
    tar xvf "$2" -C "$(dirname $2)"
    ;;
term)
    xfce4-terminal --working-directory="$2"
    ;;
feh)
    feh --bg-scale "$2"
    ;;
thumb)
    declare dest="$(dirname $2)/thumb_$(basename $2)"
    convert -resize 13% "$2" "$dest"
    ;;
unzip)
    unzip "$2" -d "$(dirname $2)"
    ;;
unrar)
    unrar x "$2" "$(dirname $2)"
    ;;
esac

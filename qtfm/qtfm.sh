#!/bin/bash
#set -euo pipefail

declare -r action_path="/tmp/qtfm/action"
declare -r files_path="/tmp/qtfm/files"

check_paste_files() {
    if [ ! -f "$action_path" ] || [ ! -f "$files_path" ]
    then
        exit 1
    fi
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
    check_paste_files
    declare -r action=$(cat "$action_path")
    while IFS= read -r line
    do
        if [ ! -e "$line" ] # check if source exists
        then
            zenity --error --no-wrap --text="$line does not exist"
        else
            declare bn="$(basename $line)"
            declare code=0
            if [ -e "$2/$bn" ]
            then
                zenity --question --no-wrap --text="$bn exists, replace/merge?"
                code=$?
            fi
            if [ "$code" -eq 0 ]
            then
                declare cmd=($action)
                "${cmd[@]}" "$line" "$2" | zenity --progress --pulsate --no-cancel --auto-close --text="$action $line to $2"
            fi
        fi
    done < "$files_path"
    ;;
rm)
    rm -rf "${@:2}"
    ;;
copypath)
    echo -n "$2" | xclip -i -selection clipboard
    ;;
esac

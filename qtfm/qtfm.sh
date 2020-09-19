#!/bin/bash
set -euo pipefail

declare -r action_path="/tmp/qtfm/action"
declare -r files_path="/tmp/qtfm/files"
declare -r base_dir="$(dirname "$(readlink -f "${0}")")"

spin() {
    declare -r pid1="$!"
    sleep 0.2
    kill -0 "${pid1}" &> /dev/null
    if [ "$?" -eq 0 ]
    then
        trap "kill ${pid1}" HUP
        tail -f /dev/null | zenity --progress --pulsate --auto-kill --text="${1}" &
        declare -r pid2="$!"
        wait "${pid1}"
        kill "${pid2}"
    fi
}

case "${1}" in
rm)
    rm -rf "${@:2}";;
copypath)
    echo -n "${2}" | xclip -i -selection clipboard;;
term)
    xfce4-terminal --working-directory="${2}";;
vscode)
    code --folder-uri "${2}";;
feh)
    feh --bg-scale "${2}";;
thumb)
    convert -resize 13% "${2}" "thumb_${2}";;
extract)
    tar xvf "${2}" &
    spin "extracting ${2}";;
unzip)
    unzip "${2}" & 
    spin "extracting ${2}";;
unrar)
    unrar x "${2}" &
    spin "extracting ${2}";;
gzip)
    tar cvzf "${2}.tar.gz" "${@:3}" &
    spin "creating archive ${2}.tar.gz";;
sleep)
    sleep 37 &
    spin "sleeping"
esac

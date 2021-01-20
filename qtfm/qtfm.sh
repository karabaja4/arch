#!/bin/bash
# shellcheck disable=SC2002

set -euo pipefail

spin() {
    local -r pid="${!}"
    sleep 0.1
    if kill -0 "${pid}" &> /dev/null
    then
        # init fifo
        local -r fifo="$(mktemp -u)"
        mkfifo "${fifo}"

        trap 'kill "${pid}"' HUP
        cat "${fifo}" | zenity --progress --pulsate --auto-close --auto-kill --text="${1}" &
        wait "${pid}"
        echo "" > "${fifo}"
        rm -f "${fifo}"
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
    unzip -o "${2}" &
    spin "extracting ${2}";;
unrar)
    unrar x "${2}"&
    spin "extracting ${2}";;
gzip)
    tar cvzf "${2}.tar.gz" "${@:3}" &
    spin "creating archive ${2}.tar.gz";;
zip)
    zip -r "${2}.zip" "${@:3}" &
    spin "creating archive ${2}.tar.gz";;
sleep)
    sleep 10 &
    spin "sleeping";;
# echo)
#     echo "hello" &
#     spin "echoing";;
esac

#!/bin/sh

_run() {
    "${@}" > /dev/null 2>&1
}

case "${1}" in
terminal)
    _run xfce4-terminal
    ;;
chromium)
    _run chromium
    ;;
firefox)
    _run firefox
    ;;
qtfm)
    _run qtfm
    ;;
qbittorrent)
    _run qbittorrent
    ;;
qtextpad)
    _run qtextpad
    ;;
code)
    _run code
    ;;
azuredatastudio)
    _run azuredatastudio
    ;;
sqlite)
    _run /opt/ssh-sqlite-manager-linux-x64/ssh-sqlite-manager
    ;;
virtualbox)
    _run VirtualBox
    ;;
postman)
    _run postman
    ;;
slack)
    _run slack -s
    ;;
teams)
    _run /home/igor/arch/misc/teams/teams2
    ;;
discord)
    _run /usr/bin/apulse /usr/bin/discord
    ;;
skype)
    _run chromium --app=https://web.skype.com
    ;;
paint)
    _run chromium --app=https://jspaint.app --incognito
    ;;
vlc)
    _run vlc
    ;;
obs)
    _run obs
    ;;
gaming)
    xdotool key ctrl+alt+space
    ;;
pd2)
    export __GL_FSAA_MODE=11
    cd /home/igor/.wine/drive_c/d2/ProjectD2 || exit
    _run wine Game.exe
    ;;
wow)
    _run wine /home/igor/.wine/drive_c/wow/WoW.exe
    ;;
openmw)
    _run openmw-launcher
    ;;
*)
    echo "unknown app"
    ;;
esac
#!/bin/sh

_detach() {
    ( "${@}" & ) > /dev/null 2>&1
}

case "${1}" in
terminal)
    _detach xfce4-terminal
    ;;
chromium)
    _detach chromium
    ;;
firefox)
    _detach firefox
    ;;
qtfm)
    _detach qtfm
    ;;
qbittorrent)
    _detach qbittorrent
    ;;
qtextpad)
    _detach qtextpad
    ;;
code)
    _detach code
    ;;
azuredatastudio)
    _detach azuredatastudio
    ;;
sqlite)
    _detach /opt/ssh-sqlite-manager-linux-x64/ssh-sqlite-manager
    ;;
virtualbox)
    _detach VirtualBox
    ;;
postman)
    _detach postman
    ;;
slack)
    _detach slack -s
    ;;
teams)
    _detach /home/igor/arch/misc/teams/teams2
    ;;
discord)
    _detach /usr/bin/apulse /usr/bin/discord
    ;;
skype)
    _detach chromium --app=https://web.skype.com
    ;;
paint)
    _detach chromium --app=https://jspaint.app --incognito
    ;;
vlc)
    _detach vlc
    ;;
obs)
    _detach obs
    ;;
gaming)
    xdotool key ctrl+alt+space
    ;;
pd2)
    export __GL_FSAA_MODE=11
    cd /home/igor/.wine/drive_c/d2/ProjectD2 || exit
    _detach wine Game.exe
    ;;
wow)
    _detach wine /home/igor/.wine/drive_c/wow/WoW.exe
    ;;
openmw)
    _detach openmw-launcher
    ;;
*)
    echo "unknown app"
    ;;
esac

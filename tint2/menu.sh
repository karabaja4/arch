#!/bin/sh

# dbus info for launched apps
# export DBUS_SESSION_BUS_ADDRESS="unix:path=/tmp/dbus-H5gshkgIVu,guid=c18e8027cd4de7167f51739364a5ea69"

# nvidia-settings --query=fsaa --verbose

# $HOME/.config/glib-2.0/settings/keyfile
# filepicker settings
export GSETTINGS_BACKEND="keyfile"
export ALSOFT_DRIVERS="alsa"

_run() {
    exec "${@}" > /dev/null 2>&1
}

_load_apulse() {
    export LD_LIBRARY_PATH="/usr/lib/apulse${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
}

# _keypress() {
#     xdotool key "${@}"
#     xdotool keyup "${@}"
# }

case "${1}" in
terminal)
    _run termite2
    ;;
firefox)
    _load_apulse
    _run firefox-socket
    ;;
# qtfm)
#     _run qtfm
#     ;;
chromium)
    _run chromium
    ;;
# qbittorrent)
#     _run qbittorrent
#     ;;
qtextpad)
    _run qtextpad
    ;;
code)
    _run code
    ;;
azuredatastudio)
    _run azuredatastudio --disable-keytar
    ;;
virtualbox)
    _run VirtualBox
    ;;
# vmware)
#     _run vmware
#     ;;
# slack)
#     _run slack --start-maximized --disable-smooth-scrolling
#     ;;
# teams)
#     _load_apulse
#     _run /usr/share/teams/teams --disable-namespace-sandbox --disable-setuid-sandbox
#     ;;
discord)
    #_run chromium --disable-gpu --start-maximized --disable-smooth-scrolling --app=https://discord.com/app
    _load_apulse
    _run discord --disable-smooth-scrolling
    ;;
# skype)
#     _load_apulse
#     _run /usr/share/skypeforlinux/skypeforlinux --disable-gpu
#     ;;
flameshot)
    _run /home/igor/arch/scripts/flameshot.sh
    ;;
# paint)
#     #rm -f "/home/igor/.config/chromium/Default/Local Storage/leveldb/"*
#     #_run chromium --start-maximized --disable-smooth-scrolling --disable-audio-output --app=https://jspaint.app
#     #_run /home/igor/arch/mspaint/mspaint.sh
#     ;;
onlyoffice)
    _run onlyoffice-desktopeditors
    ;;
# thunderbird)
#     _run thunderbird
#     ;;
zoom)
    _load_apulse
    _run zoom
    ;;
# work)
#     _run /home/igor/arch/scripts/work.sh
#     ;;
# krita)
#     _run krita
#     ;;
# inkscape)
#     _run inkscape
#     ;;
# vlc)
#     _run vlc
#     ;;
# obs)
#     _run obs
#     ;;
kvirc)
    _run kvirc
    ;;
vncviewer)
    _run vncviewer
    ;;
bruno)
    _run bruno
    ;;
# gaming)
#     _keypress "Super_L+0"
#     ;;
pd2)
    #export __GL_FSAA_MODE=11
    cd /home/igor/games/pd2/ProjectD2 || exit
    _run wine Game.exe -3dfx
    ;;
wow)
    # _run /home/igor/games/turtlewow/TurtleWoW.AppImage
    cd /home/igor/games/turtlewow || exit
    _run wine WoW.exe
    ;;
# openmw)
#     _run openmw-launcher
#     ;;
# quake3)
#     _run quake3
#     ;;
# openjk)
#     export __GL_FSAA_MODE=5
#     _run openjk
#     ;;
*)
    echo "unknown app"
    ;;
esac

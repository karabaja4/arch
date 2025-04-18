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
    export GDK_SCALE=1
    _run termite
    ;;
# firefox)
#     _run firefox-socket
#     ;;
# qtfm)
#     _run qtfm
#     ;;
chromium)
    export GDK_SCALE=2
    _run chromium
    ;;
# qbittorrent)
#     _run qbittorrent
#     ;;
qtextpad)
    _run qtextpad
    ;;
code)
    export GDK_SCALE=2
    _run code
    ;;
azuredatastudio)
    export GDK_SCALE=2
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
    export GDK_SCALE=2
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
    export GDK_SCALE=2
    _run onlyoffice-desktopeditors
    ;;
# thunderbird)
#     _run thunderbird
#     ;;
# zoom)
#     _run zoom
#     ;;
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
postman)
    _run postman
    ;;
# gaming)
#     _keypress "Super_L+0"
#     ;;
# pd2)
#     #export __GL_FSAA_MODE=11
#     cd /home/igor/.wine/drive_c/d2/ProjectD2 || exit
#     _run wine Game.exe -3dfx
#     ;;
# wow)
#     rm -r /home/igor/.wine/drive_c/wow/WDB
#     _run wine /home/igor/.wine/drive_c/wow/WoW.exe
#     ;;
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

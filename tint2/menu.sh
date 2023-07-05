#!/bin/sh

# dbus info for launched apps
# export DBUS_SESSION_BUS_ADDRESS="unix:path=/tmp/dbus-H5gshkgIVu,guid=c18e8027cd4de7167f51739364a5ea69"

# nvidia-settings --query=fsaa --verbose

# $HOME/.config/glib-2.0/settings/keyfile
# filepicker settings
export GSETTINGS_BACKEND="keyfile"

_run() {
    exec "${@}" > /dev/null 2>&1
}

_load_apulse() {
    export LD_LIBRARY_PATH="/usr/lib/apulse${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
}

_keypress() {
    xdotool key "${@}"
    xdotool keyup "${@}"
}

case "${1}" in
terminal)
    _run xfce4-terminal
    ;;
firefox)
    _run firefox-socket
    ;;
qtfm)
    _run qtfm
    ;;
chromium)
    _run chromium --start-maximized --disable-smooth-scrolling
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
virtualbox)
    _run VirtualBox
    ;;
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
    _run flameshot
    ;;
paint)
    rm -f "/home/igor/.config/chromium/Default/Local Storage/leveldb/"*
    _run chromium --start-maximized --disable-smooth-scrolling --disable-audio-output --app=https://jspaint.app
    ;;
onlyoffice)
    _run onlyoffice
    ;;
krita)
    _run krita
    ;;
inkscape)
    _run inkscape
    ;;
vlc)
    _run vlc
    ;;
obs)
    _run obs
    ;;
kvirc)
    _run kvirc
    ;;
gaming)
    _keypress "Super_L+0"
    ;;
pd2)
    #export __GL_FSAA_MODE=11
    cd /home/igor/.wine/drive_c/d2/ProjectD2 || exit
    _run wine Game.exe -3dfx
    ;;
wow)
    rm -r /home/igor/.wine/drive_c/wow/WDB
    _run wine /home/igor/.wine/drive_c/wow/WoW.exe
    ;;
openmw)
    _run openmw-launcher
    ;;
quake3)
    _run quake3
    ;;
openjk)
    export __GL_FSAA_MODE=5
    _run openjk
    ;;
*)
    echo "unknown app"
    ;;
esac

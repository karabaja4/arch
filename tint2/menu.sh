#!/bin/sh

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

case "${1}" in
terminal)
    _run termite2
    ;;
chromium)
    _run chromium
    ;;
qtextpad)
    _run qtextpad
    ;;
code)
    _run code
    ;;
azuredatastudio)
    _run azuredatastudio --disable-keytar --force-device-scale-factor=1.75
    ;;
virtualbox)
    _run VirtualBox
    ;;
discord)
    _load_apulse
    _run discord --disable-smooth-scrolling --force-device-scale-factor=1.75
    ;;
flameshot)
    _run /home/igor/arch/scripts/flameshot.sh
    ;;
onlyoffice)
    _run onlyoffice-desktopeditors
    ;;
kvirc)
    _run kvirc
    ;;
vncviewer)
    _run vncviewer
    ;;
bruno)
    _run bruno
    ;;
pd2)
    cd /home/igor/games/pd2/ProjectD2 || exit
    _run wine Game.exe -3dfx
    ;;
wow)
    export LD_PRELOAD="/usr/lib/libwayland-client.so.0:/usr/lib/libwayland-egl.so.1:/usr/lib/libwayland-cursor.so.0"
    _run /home/igor/games/turtlewow/TurtleWoW.AppImage
    ;;
*)
    printf '%s\n' "unknown app"
    ;;
esac

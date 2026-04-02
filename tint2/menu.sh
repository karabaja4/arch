#!/bin/sh

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
firefox)
    _run firefox-socket
    ;;
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
discord)
    _run chromium --app="https://discord.com/app" --user-data-dir=/home/igor/.config/chromium-discord
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
    cd '/home/igor/.wine/drive_c/Games/D2/ProjectD2/' || exit
    _run wine Game.exe -3dfx
    ;;
nfs4)
    cd '/home/igor/.wine/drive_c/Games/NFS4' || exit
    _run wine nfs4.exe
    ;;
wow)
    export LD_PRELOAD="/usr/lib/libwayland-client.so.0:/usr/lib/libwayland-egl.so.1:/usr/lib/libwayland-cursor.so.0"
    _run /home/igor/games/turtlewow/TurtleWoW.AppImage
    ;;
*)
    printf '%s\n' "unknown app"
    ;;
esac

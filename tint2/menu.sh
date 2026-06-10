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
firefox)
    _run firefox-socket
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
bruno)
    _run bruno
    ;;
virtualbox)
    _run VirtualBox
    ;;
discord)
    _run chromium --app="https://discord.com/app" --user-data-dir=/home/igor/.config/chromium-discord
    ;;
kvirc)
    _run kvirc
    ;;
flameshot)
    _run /home/igor/arch/scripts/flameshot.sh
    ;;
onlyoffice)
    _run onlyoffice-desktopeditors
    ;;
vncviewer)
    _run vncviewer
    ;;
*)
    printf '%s\n' "unknown app"
    ;;
esac

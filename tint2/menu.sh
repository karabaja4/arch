#!/bin/sh

# dbus info for launched apps
# _dbus_address="$(ss -lp --unix | grep "dbus-daemon" | awk '{print substr($5,2)}')"
# if [ -n "${_dbus_address}" ]
# then
#     export DBUS_SESSION_BUS_ADDRESS="unix:abstract=${_dbus_address}"
# fi

# nvidia-settings --query=fsaa --verbose

_run() {
    exec "${@}" > /dev/null 2>&1
}

_load_apulse() {
    export LD_LIBRARY_PATH="/usr/lib/apulse${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
}

case "${1}" in
terminal)
    _run xfce4-terminal
    ;;
chromium)
    _run chromium --disable-gpu --start-maximized
    ;;
firefox)
    _run firefox-socket-control
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
    _run slack --disable-smooth-scrolling --start-maximized
    ;;
teams)
    _load_apulse
    _run /usr/share/teams/teams --disable-namespace-sandbox --disable-setuid-sandbox
    ;;
discord)
    _run chromium --disable-gpu --start-maximized --app=https://discord.com/app
    ;;
skype)
    _load_apulse
    _run /usr/share/skypeforlinux/skypeforlinux --disable-gpu
    ;;
paint)
    _run chromium --start-maximized --incognito --app=https://jspaint.app
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
    xdotool key ctrl+alt+space
    xdotool keyup ctrl+alt+space
    ;;
pd2)
    export __GL_FSAA_MODE=11
    cd /home/igor/.wine/drive_c/d2/ProjectD2 || exit
    _run wine Game.exe
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
flameshot)
    #mkdir -p /tmp/screenshots
    #flameshot gui --raw | tee /tmp/screenshots/flameshot.png | xclip -i -selection clipboard -t image/png
    _run flameshot
    ;;
*)
    echo "unknown app"
    ;;
esac

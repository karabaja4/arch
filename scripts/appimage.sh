#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"

set -e

doas modprobe fuse

_latest() {
    find "$(dirname "${1}")" -name "$(basename "${1}")" -printf "%Ts/%p\n" | sort -nr | cut -d'/' -f2- | head -n1
}

_exec() {
    if [ -z "${1}" ]
    then
        _err 100 "Appimage not found."
    fi
    exec "${@}" 
}

case "$(_script_ln)" in
onlyoffice-desktopeditors)
    _exec /opt/appimage/DesktopEditors-x86_64.AppImage "${@}"
    ;;
krita)
    _exec "$(_latest /opt/appimage/krita-*-x86_64.appimage)" "${@}"
    ;;
inkscape)
    _exec "$(_latest /opt/appimage/Inkscape-*-x86_64.AppImage)" "${@}"
    ;;
"$(_script_fn)")
    _echo "Symlink the script to the app, e.g. ln -s $(_script_fp) /usr/bin/onlyoffice-desktopeditors"
    ;;
*)
    _echo "Unknown app"
    ;;
esac

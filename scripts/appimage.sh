#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"

set -e

doas modprobe fuse

case "$(_script_ln)" in
onlyoffice-desktopeditors)
    exec "/opt/appimage/DesktopEditors-x86_64.AppImage" "${@}"
    ;;
krita)
    exec "/opt/appimage/krita-5.2.0-x86_64.appimage" "${@}"
    ;;
inkscape)
    exec "/opt/appimage/Inkscape-5ab75fa-x86_64.AppImage" "${@}"
    ;;
bruno)
    exec "/opt/appimage/bruno_1.2.0_x86_64_linux.AppImage" "${@}"
    ;;
"$(_script_fn)")
    _echo "Symlink the script to the app, e.g. ln -s $(_script_fp) /usr/bin/onlyoffice-desktopeditors"
    ;;
*)
    _echo "Unknown app"
    ;;
esac

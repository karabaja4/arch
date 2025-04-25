#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"

set -e

doas modprobe fuse

# if script is symlinked, ${0} prints link name

case "$(basename "${0}")" in
onlyoffice-desktopeditors)
    exec "/opt/appimage/DesktopEditors-x86_64.AppImage" "${@}"
    ;;
krita)
    exec "/opt/appimage/krita-5.2.9-x86_64.AppImage" "${@}"
    ;;
inkscape)
    exec "/opt/appimage/Inkscape-091e20e-x86_64.AppImage" "${@}"
    ;;
bruno)
    exec "/opt/appimage/bruno_1.3.0_x86_64_linux.AppImage" "${@}"
    ;;
zoom)
    exec "/opt/appimage/Zoom_Workplace-6.4.3.827.glibc2.27-x86_64.AppImage" "${@}"
    ;;
"$(_script_filename)")
    _echo "Symlink the script to the app, e.g. ln -s $(_script_path) /usr/bin/onlyoffice-desktopeditors"
    ;;
*)
    _echo "Unknown app"
    ;;
esac

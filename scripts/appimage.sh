#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"

set -e

doas modprobe fuse

# if script is symlinked, ${0} prints link name

case "$(basename "${0}")" in
krita)
    exec "/opt/appimage/krita-5.2.11-x86_64.AppImage" "${@}"
    ;;
inkscape)
    exec "/opt/appimage/Inkscape-091e20e-x86_64.AppImage" "${@}"
    ;;
bruno)
    exec "/opt/appimage/bruno_2.10.0_x86_64_linux.AppImage" --force-device-scale-factor=1.75 "${@}"
    ;;
"$(_script_filename)")
    _echo "Symlink the script to the app, e.g. ln -s $(_script_path) /usr/local/bin/krita"
    ;;
*)
    _echo "Unknown app"
    ;;
esac

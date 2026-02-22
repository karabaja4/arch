#!/bin/sh
. "$(dirname "$(readlink -f "${0}")")/_lib.sh"
set -e

_script_path="$(readlink -f "${0}")"
_script_filename="$(basename "${_script_path}")"

doas modprobe fuse

# if script is symlinked, ${0} prints link name

case "$(basename "${0}")" in
krita)
    export QT_ENABLE_HIGHDPI_SCALING=0
    exec "/opt/appimage/krita-5.2.15-x86_64.AppImage" "${@}"
    ;;
bruno)
    exec "/opt/appimage/bruno_3.1.3_x86_64_linux.AppImage" --force-device-scale-factor=1.75 "${@}"
    ;;
"${_script_filename}")
    _echo "Symlink the script to the app, e.g. ln -s ${_script_path} /usr/local/bin/krita"
    ;;
*)
    _echo "Unknown app"
    ;;
esac

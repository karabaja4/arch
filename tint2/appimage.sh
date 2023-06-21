#!/bin/sh
set -e

doas modprobe fuse

_echo() {
    printf '%s\n' "${1}"
}

_filename="$(basename "${0}")"
_scriptpath="$(readlink -f "${0}")"
_scriptname="$(basename "${_scriptpath}")"

case "${_filename}" in
onlyoffice)
    exec /opt/appimage/DesktopEditors-x86_64.AppImage "${@}"
    ;;
krita)
    exec /opt/appimage/krita-*-x86_64.appimage "${@}"
    ;;
inkscape)
    exec /opt/appimage/Inkscape-*-x86_64.AppImage "${@}"
    ;;
"${_scriptname}")
    _echo "Symlink the script to the app, e.g. ln -s ${_scriptpath} /usr/bin/onlyoffice"
    ;;
*)
    _echo "Unknown app"
    ;;
esac

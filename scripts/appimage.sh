#!/bin/sh
set -e

doas modprobe fuse

_echo() {
    printf '%s\n' "${1}"
}

_latest() {
    find "$(dirname "${1}")" -name "$(basename "${1}")" -printf "%Ts/%p\n" | sort -nr | cut -d'/' -f2- | head -n1
}

_exec() {
    if [ -z "${1}" ]
    then
        _echo "Appimage not found."
        exit 1
    fi
    exec "${@}" 
}

_filename="$(basename "${0}")"
_scriptpath="$(readlink -f "${0}")"
_scriptname="$(basename "${_scriptpath}")"

case "${_filename}" in
onlyoffice-desktopeditors)
    _exec /opt/appimage/DesktopEditors-x86_64.AppImage "${@}"
    ;;
krita)
    _exec "$(_latest /opt/appimage/krita-*-x86_64.appimage)" "${@}"
    ;;
inkscape)
    _exec "$(_latest /opt/appimage/Inkscape-*-x86_64.AppImage)" "${@}"
    ;;
"${_scriptname}")
    _echo "Symlink the script to the app, e.g. ln -s ${_scriptpath} /usr/bin/onlyoffice-desktopeditors"
    ;;
*)
    _echo "Unknown app"
    ;;
esac

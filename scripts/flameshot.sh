#!/bin/sh
set -eu

# scaling screws screens up
export QT_ENABLE_HIGHDPI_SCALING=0

_path='/tmp/flameshot'
_png="${_path}.png"
_bmp="${_path}.bmp"

_copy() {
    _ext="${1##*.}"
    printf "Copying %s to clipboard as %s\n" "${1}" "${_ext}"
    xclip -in -selection clipboard -t "image/${_ext}" "${1}"
}

_vbox() {
    _wmout="$(wmctrl -l 2>/dev/null)"
    case "${_wmout}" in
        *'FreeRDP:'* | \
        *'ws2008r2-v2 [Running] - Oracle VirtualBox'*)
            return 0
            ;;
    esac
    return 1
}

rm -f "${_png}" "${_bmp}"
flameshot gui -r > "${_png}"

if [ -s "${_png}" ]
then
    if [ "${1-}" = '--no-convert' ] || ! _vbox
    then
        _copy "${_png}"
    else
        printf 'Converting %s to %s\n' "${_png}" "${_bmp}"
        magick "${_png}" "bmp:${_bmp}"
        _copy "${_bmp}"
    fi
fi

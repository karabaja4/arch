#!/bin/sh

_path='/tmp/flameshot.png'

rm -rf "${_path}"
flameshot gui -r > "${_path}"

if [ -s "${_path}" ]
then
    _wmout="$(wmctrl -l 2>/dev/null)"
    _type='image/png'

    # virtualbox only supports bmp
    case "${_wmout}" in
    *'FreeRDP:'* | *'[Running] - Oracle VirtualBox'* )
        magick "${_path}" "bmp:${_path}"
        _type='image/bmp'
        ;;
    esac

    xclip -in -selection clipboard -t "${_type}" "${_path}"
fi

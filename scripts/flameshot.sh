#!/bin/sh
set -eu

# scaling screws screens up
export QT_ENABLE_HIGHDPI_SCALING=0

_path='/tmp/flameshot.png'

rm -rf "${_path}"
flameshot gui -r > "${_path}"

if [ -s "${_path}" ]
then
    _wmout="$(wmctrl -l 2>/dev/null)"
    _type='image/png'

    # virtualbox only supports bmp
    if printf '%s\n' "${_wmout}" | grep -q '\[Running\] - Oracle VirtualBox'
    then
        printf 'Converting %s to bmp\n' "${_path}"
        magick "${_path}" "bmp:${_path}"
        _type='image/bmp'
    fi

    xclip -in -selection clipboard -t "${_type}" "${_path}"
fi

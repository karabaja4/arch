#!/bin/sh
. '/home/igor/arch/scripts/flameshot.sh'

_dest='/tmp/feh'
_format='png'

if _vbox
then
    _format='bmp'
fi

magick "${1}" "${_format}:${_dest}.${_format}"
_copy "${_dest}.${_format}"

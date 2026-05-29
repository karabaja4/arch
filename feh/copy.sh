#!/bin/sh

_format="${2}"
_dest="/tmp/feh.${_format}"

magick "${1}" "${_format}:${_dest}"
xclip -in -selection clipboard -t "image/${_format}" "${_dest}"

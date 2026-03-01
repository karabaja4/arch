#!/bin/sh

_dest="/tmp/feh.png"
magick "${1}" "png:${_dest}"
xclip -in -selection clipboard -t "image/png" "${_dest}"

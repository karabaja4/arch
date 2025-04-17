#!/bin/sh

_path="/tmp/flameshot.png"

rm -rf "${_path}"
flameshot gui -r > "${_path}"

if [ -s "${_path}" ]
then
    xclip -in -selection clipboard -t "image/png" "${_path}"
fi

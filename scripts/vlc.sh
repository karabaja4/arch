#!/bin/bash

xset -dpms
if [ -n "${1}" ]
then
    /usr/bin/vlc "${1}"
else
    /usr/bin/vlc
fi
xset +dpms
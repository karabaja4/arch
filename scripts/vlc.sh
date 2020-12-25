#!/bin/bash

xset -dpms
/usr/bin/vlc "$@"
xset +dpms
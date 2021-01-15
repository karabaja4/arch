#!/bin/bash

xset s off -dpms
/usr/bin/vlc "$@"
xset s on +dpms
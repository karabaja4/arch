#!/bin/sh

case "${1}" in
pd2)
    sh -c "cd /home/igor/.wine/drive_c/d2/ProjectD2 && __GL_FSAA_MODE=11 wine Game.exe"
    ;;
wow)
    wine /home/igor/.wine/drive_c/wow/WoW.exe
    ;;
openmw)
    openmw-launcher
    ;;
*)
    echo "unknown app"
    ;;
esac

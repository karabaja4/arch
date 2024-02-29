#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"

_herbe() {
    if command -v herbe > /dev/null 2>&1
    then
        if [ "$(id -u)" -eq 0 ]
        then
            XAUTHORITY="$(_passwd 6)/.local/share/sx/xauthority" DISPLAY=":1" herbe "${@}"
        else
            herbe "${@}"
        fi
    fi
}

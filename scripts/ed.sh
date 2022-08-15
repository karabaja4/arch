#!/bin/sh

# ln -sf /home/igor/arch/scripts/ed.sh /usr/bin/ed

if [ "${TERM}" = "linux" ] || [ "$(id -u)" -eq 0 ]
then
    # no GUI or root
    nano "${1}"
else
    qtextpad "${1}" > /dev/null 2>&1
fi

#!/bin/sh

# ln -sf /home/igor/arch/scripts/ed.sh /usr/bin/ed

if [ "${TERM}" = "linux" ]
then
    nano "${1}"
else
    qtextpad --syntax "INI Files" "${1}" > /dev/null 2>&1
fi

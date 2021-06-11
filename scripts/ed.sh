#!/bin/sh

# sudo ln -sf /home/igor/arch/scripts/ed.sh /usr/bin/ed

if [ "${TERM}" = "linux" ]
then
    nano "${1}" > /dev/null 2>&1
else
    fpad "${1}" > /dev/null 2>&1 &
fi

#!/bin/sh

# ln -sf /home/igor/arch/scripts/ed.sh /usr/bin/ed

if [ "${TERM}" = "linux" ]
then
    nano "${1}"
else
    featherpad -s "${1}" > /dev/null 2>&1 &
fi

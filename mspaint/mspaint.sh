#!/bin/sh

/home/igor/arch/scripts/mspaint.sh &
wine64 /home/igor/arch/mspaint/xp64/mspaint.exe
kill -- -$$
printf '%s\n' 'End.'
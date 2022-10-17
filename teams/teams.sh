#!/bin/sh

export LD_LIBRARY_PATH="/usr/lib/apulse${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
exec /usr/share/teams/teams "${@}" --disable-namespace-sandbox --disable-setuid-sandbox > /dev/null 2>&1

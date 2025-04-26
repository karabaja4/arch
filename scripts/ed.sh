#!/bin/sh
set -eu

# ln -sf /home/igor/arch/scripts/ed.sh /usr/local/bin/ed

_run() {
    ( "${@}" & ) > /dev/null 2>&1
}

if [ "${TERM}" = "linux" ] || [ "$(id -u)" -eq 0 ]
then
    # no GUI or root
    exec nano "${1-}"
else
    _run qtextpad "${1-}"
fi

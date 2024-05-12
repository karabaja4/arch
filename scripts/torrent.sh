#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"

if [ -f "${1}" ]
then
    _disk="${HOME}/_disk"
    if mountpoint -q "${_disk}"
    then
        _drop="${_disk}/drop"
        if [ -d "${_drop}" ]
        then
            mv "${1}" "${_drop}"
            _herbe "Moved \"$(basename "${1}")\" to \"${_drop}\""
        fi
    fi
fi

#!/bin/sh

if [ -f "${1}" ]
then
    _disk="${HOME}/_disk"
    if mountpoint -q "${_disk}"
    then
        _drop="${_disk}/drop"
        if [ -d "${_drop}" ]
        then
            mv "${1}" "${_drop}"
        fi
    fi
fi

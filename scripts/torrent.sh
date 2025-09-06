#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"

if [ -f "${_arg1}" ]
then
    _disk="${HOME}/_disk"
    if mountpoint -q "${_disk}"
    then
        _drop="${_disk}/drop"
        if [ -d "${_drop}" ]
        then
            # this will append .moving suffix to a file
            # so multiple instances of the script see only one file
            _moving_file="${_arg1}.moving"
            if [ -e "${_moving_file}" ]
            then
                _fatal "${_moving_file} exists."
            fi
            if mv "${_arg1}" "${_moving_file}"
            then
                if mv "${_moving_file}" "${_drop}/"
                then
                    _herbe "Moved \"$(basename "${_arg1}")\" to \"${_drop}\""
                fi
            fi
        fi
    fi
fi

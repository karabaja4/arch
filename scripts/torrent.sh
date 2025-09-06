#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"
set -e

case "${_arg1}" in
    *.torrent) 
        ;;
    *)
        _fatal "${_arg1} is not a .torrent file."
        ;;
esac

if [ -f "${_arg1}" ]
then
    _disk="${HOME}/_disk"
    if mountpoint -q "${_disk}"
    then
        _drop="${_disk}/drop"
        if [ -d "${_drop}" ]
        then
            # temp file to prevent concurrency issues
            _moving_file="${_arg1}.moving"
            if [ -e "${_moving_file}" ]
            then
                _fatal "${_moving_file} exists."
            fi
            mv "${_arg1}" "${_moving_file}"

            # temp file to drop file
            _fn="$(basename "${_arg1}")"
            _dest_file="${_drop}/${_fn}"
            if [ -e "${_dest_file}" ]
            then
                _fatal "${_dest_file} already exists."
            fi
            mv "${_moving_file}" "${_dest_file}"

            # notification
            _herbe "Moved \"${_fn}\" to \"${_drop}\""
        fi
    fi
fi

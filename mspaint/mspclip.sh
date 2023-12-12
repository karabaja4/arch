#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"

_mspaint="mspaint.exe"
_out="/tmp/xclip.out"

touch "${_out}"

_skip=0

while inotifywait -e close_write "${_out}" > /dev/null 2>&1
do
    if pgrep -x "${_mspaint}" > /dev/null
    then
        if [ "${_skip}" -eq 0 ]
        then
            _mime="$(file -L -E --brief --mime-type "${_out}")"
            case "${_mime}" in
                "image/bmp")
                    # convert bitmaps (copy from mspaint to outside) to png
                    # only do this if numlock is on so it's controllable
                    # because pngs can't be pasted back to mspaint
                    _numlock="$(xset q | sed -n 's/^.*Num Lock:\s*\(\S*\).*$/\1/p')"
                    _echo "NUMLOCK is ${_numlock}"
                    if [ "${_numlock}" = "on" ]
                    then
                        _echo "Converting ${_out} to png."
                        convert "${_out}" "png:${_out}"
                        xclip -selection clipboard -t "image/png" < "${_out}"
                       _skip=1
                        _echo "Skip set to 1"
                    fi
                    ;;
                "image/"*)
                    # copy everything else (copy from outside to mspaint) to bmp
                    _echo "Converting ${_out} to bmp."
                    convert "${_out}" "bmp:${_out}"
                    xclip -selection clipboard -t "image/bmp" < "${_out}"
                    _skip=1
                    _echo "Skip set to 1"
                    ;;
            esac
        else
            # reset skip
            _skip=0
            _echo "Skip set to 0"
        fi
    fi
done

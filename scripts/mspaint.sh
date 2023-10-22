#!/bin/sh
set -u

# mspaint extension for clip.sh
# complicated code that enables pasting images back and from mspaint running in wine
# just ignore this script, it's for my benefit only

_match="${1-}"
_mspaint="mspaint.exe"
_out="/tmp/xclip.out"

_log() {
    printf '[\033[35m%s\033[0m] %s\n' "${_mspaint}" "${1}" >&2
}

case "${_match}" in
"image/"*)
    if pgrep -x "${_mspaint}" > /dev/null && \
       command -v "convert" > /dev/null && \
       command -v "xset" > /dev/null
    then
        _oldmatch="${_match}"
        if [ "${_match}" = "image/bmp" ]
        then
            # convert bitmaps (copy from mspaint to outside) to png
            # only do this if numlock is on so it's controllable
            # because pngs can't be pasted back to mspaint
            _numlock="$(xset q | sed -n 's/^.*Num Lock:\s*\(\S*\).*$/\1/p')"
            _log "NUM LOCK is ${_numlock}"
            if [ "${_numlock}" = "on" ]
            then
                _match="image/png"
            fi
        else
            # copy everything else (copy from outside to mspaint) to bmp
            _match="image/bmp"
        fi
        if [ "${_oldmatch}" != "${_match}" ]
        then
            _log "Converting from ${_oldmatch} to ${_match}"
            convert "${_out}" "${_match##*/}:${_out}"
            printf '%s\n' "${_match}"
        else
            _log "Keeping ${_match}"
        fi
    fi
    ;;
esac

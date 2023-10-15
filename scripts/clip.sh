#!/bin/sh
set -u

# TARGETS configuration
_pref="
image/png
image/bmp
text/uri-list
code/file-list
"
_utf8="UTF8_STRING"

_out="/tmp/xclip.out"
_history="/tmp/xclip.history"

_log() {
    printf '\033[32m->\033[0m %s' "${1}" | xargs
}

_usage() {
    _log "Invalid arguments."
    exit 1
}

[ "${#}" -gt 0 ] && _usage

_iteration() {

    # fix for FreeRDP
    # if command -v xdotool > /dev/null 2>&1
    # then
    #     _awcn="$(xdotool getactivewindow getwindowclassname 2>/dev/null)"
    #     if [ "${_awcn}" = "xfreerdp" ]
    #     then
    #         # stay in this loop while FreeRDP is in focus so clipboard stays under ownership of FreeRDP
    #         # after FreeRDP loses focus transfer the contents into xclip so it's available to other apps
    #         _log "FreeRDP clipboard is not supported"
    #         sleep 1
    #         return 1
    #     fi
    # fi
    
    # target test of current selection
    _tc="$(xclip -selection clipboard -o -t TARGETS)"
    _tcec="${?}"
    _log "TARGETS check exited with: ${_tcec}"

    if [ "${_tcec}" -ne 0 ]
    then
        # on empty wait for any selection
        _log "Waiting on initial selection with: ${_utf8}"

        # take ownership of clipboard so we block the loop and wait for someone to take ownership
        # if this fails probably X connection is lost, so exit the script
        xclip -verbose -in -selection clipboard -t "${_utf8}" /dev/null || exit 3
    else
        _log "Clipboard targets: ${_tc}"
        _log "Preferred targets: ${_pref}"
        _log "Default targets: ${_utf8}"

        # join both lists together, and print first item of targets occuring in _pref
        _match="$(printf '%s\n%s\n%s\n' "${_tc}" "${_pref}" "${_utf8}" | grep -v '^\s*$' | awk 'a[$0]++' | head -n1)"

        if [ -n "${_match}" ]
        then
            _log "Matched target: ${_match}"

            # put clipboard content into temp file
            xclip -verbose -out -selection clipboard -t "${_match}" > "${_out}"
            _log "xclip out exited"

            # complicated code that enables pasting images back and from mspaint running in wine
            # just ignore this block, it's for my benefit only
            case "${_match}" in
            "image/"*)
                _exe="mspaint.exe"
                if pgrep -x "${_exe}" > /dev/null && \
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
                        _log "[${_exe}] Num Lock is ${_numlock}"
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
                        _log "[${_exe}] Converting from ${_oldmatch} to ${_match}"
                        convert "${_out}" "${_match##*/}:${_out}"
                    else
                        _log "[${_exe}] Not converting ${_match}"
                    fi
                fi
                ;;
            esac
            # end mspaint block

            if [ "${_match}" = "${_utf8}" ]
            then
                printf '%s\n' "$(cat "${_out}")" >> "${_history}"
                _log "Saved to history"
            fi

            # read temp file, take ownership of clipboard and wait for pastes
            # after something else is copied, xclip loses ownership and exits, and another iteration begins
            xclip -verbose -in -selection clipboard -t "${_match}" "${_out}"
            _log "xclip in exited"
        else
            _log "Unable to match targets"
            sleep 1
        fi
    fi
}

_log "$(basename "${0}") @ $(readlink /proc/$$/exe)"
while true
do
    _log "start"
    _iteration
    _log "end"
done

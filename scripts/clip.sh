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

_log() {
    printf '\033[32m->\033[0m %s' "${1}" | xargs
}

_usage() {
    _log "Invalid arguments."
    exit 1
}

[ "${#}" -gt 0 ] && _usage

_iteration() {

    if xdotool getactivewindow getwindowname | grep FreeRDP > /dev/null
    then
        _log "FreeRDP clipboard is not supported"
        sleep 1
        return 1
    fi
    
    # target test of current selection
    _tc="$(xclip -selection clipboard -o -t TARGETS)"
    _tcec=${?}
    _log "TARGETS check exited with: ${_tcec}"

    if [ "${_tcec}" -ne 0 ]
    then
        # on empty wait for any selection
        _log "Waiting on initial selection with: ${_utf8}"

        # if this fails probably X connection is lost, so exit the script
        xclip -verbose -in -selection clipboard -t "${_utf8}" < /dev/null || exit 3
    else
        _log "Clipboard targets: ${_tc}"
        _log "Preferred targets: ${_pref}"
        _log "Default targets: ${_utf8}"

        # join both lists together, and print first item of targets occuring in _pref
        _match="$(printf '%s\n%s\n%s\n' "${_tc}" "${_pref}" "${_utf8}" | grep -v '^\s*$' | awk 'a[$0]++' | head -n1)"

        if [ -n "${_match}" ]
        then
            _log "Matched target: ${_match}"
            xclip -verbose -out -selection clipboard -t "${_match}" | xclip -verbose -in -selection clipboard -t "${_match}"
            _log "xclip pipe exited"
        else
            _log "Unable to match targets"
            sleep 1
        fi
    fi
}

_log "$(basename "${0}") @ $(readlink /proc/$$/exe)"
while true
do
    _log "----------"
    _iteration
done

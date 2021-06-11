#!/bin/sh
set -u

# TARGETS configuration
_pref="
image/png
text/uri-list
code/file-list
"

_log() {
    printf '\033[32m->\033[0m %s' "${1}" | xargs
}

_usage() {
    _log "Invalid arguments."
    exit 1
}

[ "${#}" -gt 0 ] && _usage

_iteration() (
    _utf8="UTF8_STRING"

    # target test of current selection
    _tc="$(xclip -selection clipboard -o -t TARGETS)"
    _tcec=${?}
    _log "TARGETS check exited with: ${_tcec}"

    if [ "${_tcec}" -ne 0 ]
    then
        # on empty wait for any selection
        _log "Waiting on initial selection with: ${_utf8}"
        xclip -verbose -in -selection clipboard -t "${_utf8}" < /dev/null
    else
        _log "Clipboard targets: ${_tc}"
        _log "Preferred targets: ${_pref}"
        _log "Default targets: ${_utf8}"

        # join both lists together, and print first item of targets occuring in _pref
        _match="$(printf '%s\n' "${_tc}" "${_pref}" "${_utf8}" | xargs -n1 | awk 'a[$0]++' | head -n1)"

        if [ -n "${_match}" ]
        then
            _log "Matched target: ${_match}"
            # timeout fixes the issue when clients like xfreerdp stall out the clipboard
            timeout -v -s TERM -k 2 1 xclip -verbose -out -selection clipboard -t "${_match}" | xclip -verbose -in -selection clipboard -t "${_match}"
            _log "xclip exited"
        else
            _log "Unable to match targets"
            sleep 1
        fi
    fi
)

_log "$(basename "${0}") @ $(readlink /proc/$$/exe)"
while true
do
    _log "--------------------"
    _iteration
done

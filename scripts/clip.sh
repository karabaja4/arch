#!/bin/sh
set -u

# TARGETS configuration
_pref="
image/png
image/bmp
image/jpeg
text/uri-list
code/file-list
"
_utf8="UTF8_STRING"

_root_dir="/tmp/clipsh"
_image_dir="${_root_dir}/images"

# create root and image dirs
mkdir -p "${_image_dir}"

# files
_out="${_root_dir}/out"
_history="${_root_dir}/history"

_script="$(basename "${0}")"

_log() {
    printf '[\033[94m%s\033[0m] %s' "${_script}" "${1}" | xargs >&2
}

_usage() {
    _log "Invalid arguments."
    exit 1
}

[ "${#}" -gt 0 ] && _usage

_add_to_history() {
    printf '%s\n%s\n' '-----' "${1}" >> "${_history}"
    _log "Added to history ${_history}"
}

_random_digits() {
    LC_ALL=C tr -dc '0-9' < /dev/urandom | head -c "${1}"
}

_iteration() {

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
        _match="$(printf '%s\n%s\n%s\n' "${_tc}" "${_pref}" "${_utf8}" | grep -v '^[[:space:]]*$' | awk 'a[$0]++' | head -n1)"

        if [ -n "${_match}" ]
        then
            _log "Matched target: ${_match}"

            # put clipboard content into temp file
            xclip -verbose -out -selection clipboard -t "${_match}" > "${_out}"
            _log "xclip out exited"

            if [ "${_match}" = "${_utf8}" ]
            then
                _add_to_history "$(cat "${_out}")"
            fi
            
            # save images to folder
            case "${_match}" in
                image/*)
                    _image_path="${_image_dir}/$(date +%s)$(_random_digits 4).${_match#*/}"
                    cp "${_out}" "${_image_path}"
                    _log "Saved image to ${_image_path}"
                    _add_to_history "${_match}: ${_image_path}"
                    ;;
            esac

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

while true
do
    _log "Start"
    _iteration
    _log "End"
done

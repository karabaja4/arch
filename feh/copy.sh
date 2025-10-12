#!/bin/sh

_mime="$(file -L -E --brief --mime-type "${1}")"
xclip -in -selection clipboard -t "${_mime}" "${1}"

#!/bin/sh

_path="$(realpath "${1}")"
_title="$(printf '%s' "${_path}" | sed "s;${HOME};~;g")"

xfce4-terminal --title "lf: ${_title}" --command "lf ${_path}"
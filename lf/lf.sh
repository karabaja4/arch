#!/bin/sh

_path="$(realpath "$(printf '%s' "${1}" | sed 's;file://;;g')")"
xfce4-terminal --title "lf" --command "lf ${_path}"
#!/bin/sh

printf '%s (%s)' "$(cat "/home/igor/.local/share/updatecount/pacman" || printf '%s' "-")" "$(cat "/home/igor/.local/share/updatecount/aur" || printf '%s' "-")"

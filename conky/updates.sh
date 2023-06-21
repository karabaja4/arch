#!/bin/sh

printf '%s (%s)' "$(cat "/home/igor/.local/share/updatecount/pacman" || echo "-")" "$(cat "/home/igor/.local/share/updatecount/aur" || echo "-")"

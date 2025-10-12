#!/bin/sh

exec feh \
--draw-filename \
--draw-actions \
--action1 ";[c: Copy to clipboard]/home/igor/arch/feh/copy.sh %F" \
--fontpath '/usr/share/fonts/TTF' \
--font 'Roboto-Bold/8' \
--no-menus \
--scale-down \
--geometry 1280x720 \
--image-bg black \
--start-at "${@}"

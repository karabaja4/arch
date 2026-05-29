#!/bin/sh

exec feh \
--draw-filename \
--draw-actions \
--action1 ";[c: Copy as PNG]/home/igor/arch/feh/copy.sh %F png" \
--action2 ";[C: Copy as BMP]/home/igor/arch/feh/copy.sh %F bmp" \
--fontpath '/usr/share/fonts/TTF' \
--font 'Roboto-Bold/8' \
--no-menus \
--scale-down \
--geometry 1280x720 \
--image-bg black \
--start-at "${@}"

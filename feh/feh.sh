#!/bin/sh

exec feh \
--draw-filename \
--fontpath '/usr/share/fonts/TTF' \
--font 'Roboto-Bold/8' \
--no-menus \
--auto-zoom \
--scale-down \
--geometry 1280x720 \
--image-bg black \
--start-at "${@}"

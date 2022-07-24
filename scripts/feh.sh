#!/bin/sh

exec feh \
--draw-actions \
--draw-filename \
--fontpath "/usr/share/fonts/TTF" \
--font "Roboto-Bold/10" \
--action1 ';[copy]xclip -selection clipboard -t image/png -i %F' \
--no-menus \
--scale-down \
--geometry 1280x720 \
--image-bg black \
--start-at "${@}"

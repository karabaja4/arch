#!/bin/sh

exec feh \
--draw-actions \
--draw-filename \
--fontpath '/usr/share/fonts/TTF' \
--font 'Roboto-Bold/8' \
--action1 ';[to clipboard]xclip -selection clipboard -t image/png -i %F' \
--action2 ";[to ${HOME}]cp %F ${HOME}/%N" \
--action3 ';[as wallpaper]xwallpaper --stretch %F' \
--no-menus \
--scale-down \
--geometry 1280x720 \
--image-bg black \
--start-at "${@}"

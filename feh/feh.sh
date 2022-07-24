#!/bin/sh

exec feh \
--draw-actions \
--draw-filename \
--fontpath '/usr/share/fonts/TTF' \
--font 'Roboto-Bold/10' \
--action1 ';[Copy to clipboard]xclip -selection clipboard -t image/png -i %F' \
--action2 ";[Copy file to ${HOME}]cp %F ${HOME}/%N" \
--action3 ';[Set as wallpaper]xwallpaper --stretch %F' \
--no-menus \
--scale-down \
--geometry 1280x720 \
--image-bg black \
--start-at "${@}"

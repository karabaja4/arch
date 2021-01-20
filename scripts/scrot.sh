#!/bin/bash

MONITORS=$(xrandr | grep -o '[0-9]*x[0-9]*[+-][0-9]*[+-][0-9]*')
eval "$(xdotool getmouselocation --shell)"
mkdir -p /tmp/screenshots/

for mon in ${MONITORS}
do
  MONW=$(awk -F "[x+]" '{print $1}' <<< "${mon}")
  MONH=$(awk -F "[x+]" '{print $2}' <<< "${mon}")
  MONX=$(awk -F "[x+]" '{print $3}' <<< "${mon}")
  MONY=$(awk -F "[x+]" '{print $4}' <<< "${mon}")
  if (( X >= MONX && X <= MONX + MONW && Y >= MONY && Y <= MONY + MONH ))
  then
    maim -g "${MONW}x${MONH}+${MONX}+${MONY}" > "/tmp/screenshots/$(date +%s%N).png"
    exit 0
  fi
done

echo "Oh no the mouse is in the void!"
exit 1
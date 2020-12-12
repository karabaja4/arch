#!/bin/bash

declare -r running="$(wmctrl -lx | grep chromium.Chromium)"

if [ -z "$running" ]
then
      killall -q -w -0 chromium | zenity --progress --pulsate --no-cancel --auto-close --text="Waiting for previous Chromium instance to close"
else
      echo "Found window: $running"
fi

/usr/bin/chromium &> /dev/null
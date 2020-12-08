#!/bin/bash

declare running="$(wmctrl -lx | grep chromium.Chromium)"

if [ -z "$running" ]
then
      killall -q -w chromium | zenity --progress --pulsate --no-cancel --auto-close --text="Waiting for previous Chromium instance to close"
else
      echo "Found window: $running"
fi

/usr/bin/chromium &> /dev/null
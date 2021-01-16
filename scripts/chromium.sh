#!/bin/bash

killall -q -0 chromium
if (( ${?} == 0 )) # zero means chromium is running
then
      declare -r running="$(wmctrl -lx | grep chromium.Chromium)"
      if [ -z "$running" ]
      then
            killall -q -w -0 chromium | zenity --progress --pulsate --no-cancel --auto-close --text="Waiting for previous Chromium instance to close"
      else
            echo "Found window: $running"
      fi
fi

/usr/bin/chromium &> /dev/null
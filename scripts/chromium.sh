#!/bin/bash

declare running="$(wmctrl -lx | grep chromium.Chromium)"

if [ -z "$running" ]
then
      killall -q -9 chromium
else
      echo "Found window: $running"
fi

/usr/bin/chromium &> /dev/null
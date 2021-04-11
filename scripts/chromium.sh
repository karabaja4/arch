#!/bin/bash
set -uo pipefail

if killall -q -0 chromium # is chromium running?
then
    if wmctrl -lx | grep -E "chromium.Chromium|app.Chromium" # is chromium window open?
    then
        # chromium window open
        echo "Found window."
    else
        # chromium running but not open
        killall -q -w -0 chromium | zenity --progress --pulsate --no-cancel --auto-close --text="Waiting for previous Chromium instance to close"
    fi
fi

/usr/bin/chromium "$@" &> /dev/null
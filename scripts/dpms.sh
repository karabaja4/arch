#!/bin/sh
set -eu

export XAUTHORITY="${HOME}/.local/share/sx/xauthority"
export DISPLAY=":1"

xset s 0 0
xset dpms 0 0 0

# Get idle time in milliseconds
_idle_time="$(xprintidle)"

# Only continue if idle time exceeds 5 minutes (300000 ms)
if [ "${_idle_time}" -gt 300000 ]
then
    # Initialize flags
    _audio_running=0
    _vbox_running=0

    # Check if audio is running
    if grep -q "RUNNING" /proc/asound/card*/pcm*/sub*/status 2>/dev/null
    then
        _audio_running=1
    fi

    # Check if VirtualBox is running
    if wmctrl -l 2>/dev/null | grep -q "\[Running\] - Oracle VirtualBox"
    then
        _vbox_running=1
    fi

    # Determine whether to turn off the screen
    if [ "${_audio_running}" -eq 0 ] || [ "${_vbox_running}" -eq 1 ]
    then
        xset dpms force off
    fi
fi

#!/bin/sh
set -u

# kill the script if we are hovering over it
_kill_on_hover() {
    
    # get window id under mouse
    _mouse_window_id="$(xdotool getmouselocation --shell | awk -F= '/WINDOW/{print $2}')"
    
    if xwininfo -children -id "${_mouse_window_id}" | grep -q 'Window id: 0x.* "blackscreen"'
    then
        xkill -id "${_mouse_window_id}"
        return 0
    else
        return 1
    fi
}

if ! _kill_on_hover
then
    # start oled saver detached under pid 1
    ( /home/igor/arch/oled/blackscreen & ) > /dev/null 2>&1
fi

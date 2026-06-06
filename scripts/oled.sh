#!/bin/sh
set -u

# kill the program if we are hovering over it
_kill_on_hover() {
    
    # get window id under mouse
    _mouse_window_id="$(xdotool getmouselocation --shell | awk -F= '/WINDOW/{print $2}')"
    
    # see if blackscreen is the first window under root, means we're hovering over the app
    # if we're not hovering over it (e.g. we're on the second monitor), it will still be in the tree but not on the top
    _child_window_id="$(xwininfo -children -id "${_mouse_window_id}" | awk '/^[[:space:]]*0x[0-9a-f]+/ {if (/"blackscreen":/) print $1; exit}')"

    # child window is not blackscreen
    if [ -n "${_child_window_id}" ]
    then
        xkill -id "${_child_window_id}"
        return 0
    else
        return 1
    fi
}

if ! _kill_on_hover
then
    # start blackscreen detached under pid 1
    ( /home/igor/arch/oled/blackscreen & ) > /dev/null 2>&1
fi

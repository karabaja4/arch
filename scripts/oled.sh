#!/bin/sh
set -u

# kill the script if we are hovering over it
_kill_on_hover() {
    
    # get window id under mouse
    _mouse_window_id="$(xdotool getmouselocation --shell | awk -F= '/WINDOW/{print $2}')"
    
    # see if OLED saver is the first window under root, means we're hovering over the app
    if xwininfo -children -id "${_mouse_window_id}" | grep -q 'Window id: 0x[0-9a-fA-F][0-9a-fA-F]* "blackscreen"'
    then
        _pid="$(cat /tmp/blackscreen.pid)"
        [ -z "${_pid}" ] && return 1
        kill "${_pid}"
        return 0
    fi
    return 1
    
}

if ! _kill_on_hover
then
    # start oled saver detached under pid 1
    ( /home/igor/arch/oled/blackscreen & printf '%s' "${!}" > /tmp/blackscreen.pid ) > /dev/null 2>&1
fi

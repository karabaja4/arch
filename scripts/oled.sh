#!/bin/sh
set -eu

# kill the script if we are hovering over it
_kill_on_hover() {
    
    # get window id under mouse
    _mouse_window_id="$(xdotool getmouselocation --shell | awk -F= '/WINDOW/{print $2}')"
    
    # see if OLED saver is the first window under root, means we're hovering over the app
    # if we're not hovering over it (e.g. we're on the second monitor), it will still be in the tree but not on the top
    _child_window_id="$(xwininfo -children -id "${_mouse_window_id}" | awk '/^[[:space:]]*0x[0-9a-f]+/ {if (/OLED saver/) print $1; exit}')"

    # child window is not oled saver
    [ -z "${_child_window_id}" ] && return 1

    # xwininfo returns 7 digit hex number, pad to 8 digit
    _padded_window_id="$(printf "0x%08x" "$(( _child_window_id ))")"

    # find a wmctrl line with the hex id
    _wmctrl_line="$(wmctrl -l | grep "^${_padded_window_id} " | grep 'OLED saver')"

    # wmctrl should know about this window since we hovered over it, but check anyway
    [ -z "${_wmctrl_line}" ] && return 1

    # pid is in the title of oled.py, e.g. [1234]
    _pid="$(printf '%s\n' "${_wmctrl_line}" | sed 's/.*\[\([0-9][0-9]*\)\].*/\1/')"
    
    # pid should be in the title of the window, but check anway
    [ -z "${_pid}" ] && return 1

    kill "${_pid}"
}

_root="$(dirname "$(readlink -f "$0")")"

if ! _kill_on_hover
then
    # start oled saver detached under pid 1
    ( python3 "${_root}/oled.py" -m & ) > /dev/null 2>&1
fi

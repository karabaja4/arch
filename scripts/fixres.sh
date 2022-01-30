#!/bin/sh

_screen_middle="HDMI-1-1"
_screen_right="DP-1-1"
_screen_left="eDP-1-1"

_res_middle="1920x1200"
_res_right="1920x1200"
_res_left="1920x1080"

# middle
xrandr --output "${_screen_middle}" --mode "${_res_middle}" --primary

# right
xrandr --addmode "${_screen_right}" "${_res_right}"
xrandr --output "${_screen_right}" --mode "${_res_right}" --right-of "${_screen_middle}"

# left
xrandr --output "${_screen_left}" --mode "${_res_left}" --left-of "${_screen_middle}"

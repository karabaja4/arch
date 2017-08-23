#!/bin/bash

# left
xrandr --output HDMI-1 --mode 1920x1200 --primary

# right
xrandr --addmode DP-1 1920x1200
xrandr --output DP-1 --mode 1920x1200 --right-of HDMI-1

# laptop
xrandr --output eDP-1 --mode 1920x1080 --right-of DP-1

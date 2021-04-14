#!/bin/bash

# left
xrandr --output HDMI1 --mode 1920x1200 --primary

# right
xrandr --addmode DP1 1920x1200
xrandr --output DP1 --mode 1920x1200 --right-of HDMI1

# laptop
xrandr --output eDP1 --mode 1920x1080 --left-of HDMI1

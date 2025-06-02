#!/bin/sh

_res_middle="3840x2160"
_res_left="2560x1600"

_screen_middle="$(xrandr | grep "${_res_middle}+" | cut -d' ' -f1)"
_screen_left="$(xrandr | grep "${_res_left}+" | cut -d' ' -f1)"

_rate_middle="240.02"
_rate_left="240.00"

_exists() {
    _screen="${1}"
    _test="$(xrandr --output "${_screen}" 2>&1)"
    if [ -z "${_test}" ]
    then
        return 0
    else
        return 1
    fi
}

_log() {
    printf 'Setting %s to %s\n' "${1}" "${2}"
}

# middle
if _exists "${_screen_middle}"
then
    _log "${_screen_middle}" "${_res_middle}"
    xrandr --output "${_screen_middle}" --mode "${_res_middle}" --primary --rate "${_rate_middle}"
fi

# left
if _exists "${_screen_left}"
then
    _log "${_screen_left}" "${_res_left}"
    if _exists "${_screen_middle}"
    then
        xrandr --output "${_screen_left}" --mode "${_res_left}" --left-of "${_screen_middle}" --rate "${_rate_left}"
    else
        xrandr --output "${_screen_left}" --mode "${_res_left}" --rate "${_rate_left}"
    fi
fi

# set wallpapers
if _exists "${_screen_middle}" && _exists "${_screen_left}"
then
    xwallpaper --output "${_screen_middle}" --stretch "${HOME}/arch/wall/exodus_v03_5120x2880.png"
    xwallpaper --output "${_screen_left}" --stretch "${HOME}/arch/wall/exodus_v01_5120x2880.png"
elif _exists "${_screen_left}"
then
    xwallpaper --output "${_screen_left}" --stretch "${HOME}/arch/wall/exodus_v03_5120x2880.png"
fi

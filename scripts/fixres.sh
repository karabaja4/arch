#!/bin/sh

_screen_middle="DP-5.6"
_screen_right="DP-5.5"
_screen_left="eDP-1-1"

_res_middle="1920x1200"
_res_right="1920x1200"
_res_left="2560x1600"

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
    xrandr --output "${_screen_middle}" --mode "${_res_middle}" --primary
fi

# right
if _exists "${_screen_right}"
then
    _log "${_screen_right}" "${_res_right}"
    #xrandr --addmode "${_screen_right}" "${_res_right}"
    if _exists "${_screen_middle}"
    then
        xrandr --output "${_screen_right}" --mode "${_res_right}" --right-of "${_screen_middle}"
    else
        xrandr --output "${_screen_right}" --mode "${_res_right}"
    fi
fi

# left
if _exists "${_screen_left}"
then
    _log "${_screen_left}" "${_res_left}"
    if _exists "${_screen_middle}"
    then
        xrandr --output "${_screen_left}" --mode "${_res_left}" --left-of "${_screen_middle}"
    else
        xrandr --output "${_screen_left}" --mode "${_res_left}"
    fi
fi

#!/bin/sh

pkill -f conkyrc-kernel

_external_resolution='3840x2160'
_laptop_resolution='2560x1600'

_connected="$(xrandr | awk '/ connected / { print; getline; print }')"
_xrandr_count=0

_get_screen_info_by_resolution() {
    printf '%s' "${_connected}" | grep -B1 "^   ${1}"
}

_get_screen_name() {
    printf '%s' "${1}" | awk 'NR==1 { print $1 }'
}

_get_max_refresh_rate() {
    printf '%s' "${1}" | awk 'NR==2' | tr -d '+*' | awk '{$1=""; sub(/^ /, ""); print}' | tr ' ' '\n' | sort -nr | head -n1
}

_set_wallpaper() {
    printf 'Setting %s wallpaper to %s\n' "${1}" "${2}"
    xwallpaper --output "${1}" --stretch "${2}"
}

_set_xrandr() {
    _set_xrandr_output="${1}"
    _set_xrandr_mode="${2}"
    _set_xrandr_rate="${3}"
    shift 3
    printf 'Setting %s to %s@%s\n' "${_set_xrandr_output}" "${_set_xrandr_mode}" "${_set_xrandr_rate}"
    xrandr --output "${_set_xrandr_output}" --mode "${_set_xrandr_mode}" --rate "${_set_xrandr_rate}" "${@}"
    _xrandr_count=$((_xrandr_count + 1))
}

_laptop_info="$(_get_screen_info_by_resolution "${_laptop_resolution}")"

# laptop display is mandatory
if [ -z "${_laptop_info}" ]
then
    printf '%s\n' "Unable to detect internal laptop display."
    exit 1
fi

_laptop_screen_name="$(_get_screen_name "${_laptop_info}")"
_laptop_max_refresh_rate="$(_get_max_refresh_rate "${_laptop_info}")"

_external_info="$(_get_screen_info_by_resolution "${_external_resolution}")"
if [ -n "${_external_info}" ]
then
    # external display connected, it's primary, laptop is left of external display
    _external_screen_name="$(_get_screen_name "${_external_info}")"
    _external_max_refresh_rate="$(_get_max_refresh_rate "${_external_info}")"
    
    _set_xrandr "${_external_screen_name}" "${_external_resolution}" "${_external_max_refresh_rate}" --primary
    _set_xrandr "${_laptop_screen_name}" "${_laptop_resolution}" "${_laptop_max_refresh_rate}" --left-of "${_external_screen_name}"
    
    _set_wallpaper "${_external_screen_name}" "${HOME}/arch/wall/exodus_v03_5120x2880.png"
    _set_wallpaper "${_laptop_screen_name}" "${HOME}/arch/wall/exodus_v01_5120x2880.png"
else
    # only laptop display, it's primary
    _set_xrandr "${_laptop_screen_name}" "${_laptop_resolution}" "${_laptop_max_refresh_rate}" --primary
    _set_wallpaper "${_laptop_screen_name}" "${HOME}/arch/wall/exodus_v03_5120x2880.png"
fi

# conky
_i=0
while [ "${_i}" -lt "${_xrandr_count}" ]
do
    printf '%s\n' "Starting conkyrc-kernel for monitor ${_i}"
    conky -q -d -c "${HOME}/arch/conky/conkyrc-kernel" --xinerama-head "${_i}"
    _i=$((_i + 1))
done

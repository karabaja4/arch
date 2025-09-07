#!/bin/sh
set -eu

### configuration ###

_rtl_wallpapers="
${HOME}/arch/wall/exodus_v01_5120x2880.png
${HOME}/arch/wall/exodus_v03_5120x2880.png
${HOME}/arch/wall/exodus_v02_5120x2880.png
${HOME}/arch/wall/exodus_v04_5120x2880.png
${HOME}/arch/wall/exodus_v05_5120x2880.png
${HOME}/arch/wall/exodus_v06_5120x2880.png
"

_rtl_monitors="
ATNA60HU01-0
PG32UCDM
"

_primary_monitor="PG32UCDM"

#####################

# remove empty lines
_rtl_wallpapers="$(printf '%s\n' "${_rtl_wallpapers}" | grep '.')"
_rtl_monitors="$(printf '%s\n' "${_rtl_monitors}" | grep '.')"

# kill all conky instances
pkill -f conkyrc-kernel || true

_get_wallpaper_for_line() {
    printf '%s\n' "${_rtl_wallpapers}" | sed -n "${1}p"
}

# use edid data to read monitor model
_get_monitor_to_port_map() {
    xrandr --props | awk '/ connected / {d=$1} /EDID:/ {h=""; while (getline) {if ($0 !~ /^[ \t]*[0-9a-f]+$/) break; gsub(/[ \t]/,""); h=h $0} if(h!="") print d, h}' | \
    while read -r _line
    do
        _port="$(printf "%s" "${_line}" | cut -d' ' -f1)"
        _edid_data="$(printf "%s" "${_line}" | cut -d' ' -f2-)"
        _product_name="$(printf '%s\n' "${_edid_data}" | edid-decode | grep "Display Product Name:" | sed "s/.*'\(.*\)'.*/\1/" | awk '{$1=$1; print}')"
        printf "%s %s\n" "${_product_name}" "${_port}" 
    done
}

# map "<monitor name>" "<port name>"
_monitor_to_port_map="$(_get_monitor_to_port_map)"
printf '%s\n' "Monitor to Port map:"
printf '%s\n' "${_monitor_to_port_map}" | sed 's/^/-> /'
_get_port_for_monitor() {
    printf '%s\n' "${_monitor_to_port_map}" | grep "^${1} " | cut -d' ' -f2
}

_all_screen_infos="$(xrandr | awk '/ connected / { print; getline; print }')"
_get_screen_info_for_port() {
    printf '%s' "${_all_screen_infos}" | grep -A1 "^${1} connected"
}

_get_max_resolution_for_screen_info() {
    printf '%s' "${1}" | awk 'NR==2 {print $1}'
}

_get_max_refresh_rate_for_screen_info() {
    printf '%s' "${1}" | awk 'NR==2' | tr -d '+*' | awk '{$1=""; sub(/^ /, ""); print}' | tr ' ' '\n' | sort -nr | head -n1
}

_set_wallpaper() {
    printf 'Setting %s wallpaper to %s\n' "${1}" "${2}"
    xwallpaper --output "${1}" --stretch "${2}"
}

_start_conky_on_index() {
    printf 'Starting conky on screen %s\n' "${1}"
    conky -q -d -c "${HOME}/arch/conky/conkyrc-kernel" --xinerama-head "${1}"
}

# iterate monitors right to left
_configure_screens()
{
    # xrandr
    _previous_port=""
    _i=0
    for _monitor in ${_rtl_monitors}
    do
        _port="$(_get_port_for_monitor "${_monitor}")"
        if [ -z "${_port}" ]
        then
            printf 'Cannot find port for monitor: %s\n' "${_monitor}"
            exit 1
        fi
        _screen_info="$(_get_screen_info_for_port "${_port}")"
        _max_resolution="$(_get_max_resolution_for_screen_info "${_screen_info}")"
        _max_refresh_rate="$(_get_max_refresh_rate_for_screen_info "${_screen_info}")"
        
        set -- --output "${_port}" --mode "${_max_resolution}" --rate "${_max_refresh_rate}"

        if [ "${_monitor}" = "${_primary_monitor}" ]
        then
            set -- "${@}" --primary
        fi
        
        if [ "${_i}" -gt 0 ]
        then
            set -- "${@}" --right-of "${_previous_port}"
        fi
        
        printf "xrandr %s\n" "${*}"
        
        xrandr "${@}"

        _previous_port="${_port}"
        _i=$((_i + 1))
    done
    
    _total_count="${_i}"
    
    # wallpapers
    _i=0
    for _monitor in ${_rtl_monitors}
    do
        _port="$(_get_port_for_monitor "${_monitor}")"
        _wallpaper_path="$(_get_wallpaper_for_line "$((_i + 1))")"
        if [ -n "${_wallpaper_path}" ]
        then
            _set_wallpaper "${_port}" "${_wallpaper_path}"
        else
            printf 'There are not enough wallpapers for %s\n' "${_port}"
        fi
        _i=$((_i + 1))
    done
    
    # conky
    _i=0
    while [ "${_i}" -lt "${_total_count}" ]
    do
        _start_conky_on_index "${_i}"
        _i=$((_i + 1))
    done
}

_configure_screens

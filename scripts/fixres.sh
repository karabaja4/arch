#!/bin/sh
set -u

### configuration ###

_rtl_wallpapers="
${HOME}/arch/wall/exodus_v03_5120x2880.png
${HOME}/arch/wall/exodus_v01_5120x2880.png
${HOME}/arch/wall/exodus_v02_5120x2880.png
${HOME}/arch/wall/exodus_v04_5120x2880.png
${HOME}/arch/wall/exodus_v05_5120x2880.png
${HOME}/arch/wall/exodus_v06_5120x2880.png
"

_rtl_monitors="
712a4914850c9b6e3a97c14350e23dbe
5760f56f845302e774c86dd475500d09
"

_primary_monitor="712a4914850c9b6e3a97c14350e23dbe"

#####################

# argument handling
_list_only=0
if [ "${#}" -eq 1 ] && [ "${1}" = "-l" ]
then
    _list_only=1
elif [ "${#}" -ne 0 ]
then
    printf '%s\n' "Invalid parameter." >&2
    exit 1
fi

# remove empty lines
_rtl_wallpapers="$(printf '%s\n' "${_rtl_wallpapers}" | grep '.' || true)"
_rtl_monitors="$(printf '%s\n' "${_rtl_monitors}" | grep '.' || true)"

# use edid data to read monitor model
_get_monitor_to_port_map() {
    xrandr --props | awk '
    / connected / {
        display = $1
    }
    /EDID:/ {
        edid = ""
        while (getline) {
            if ($0 !~ /^[ \t]*[0-9a-f]+$/)
                break
            gsub(/[ \t]/, "")
            edid = edid $0
        }
        if (edid != "")
            print display, edid
    }' | while read -r _line
    do
        _product_port="$(printf "%s" "${_line}" | cut -d' ' -f1)"
        _edid_data="$(printf "%s" "${_line}" | cut -d' ' -f2-)"
        _product_hash="$(printf '%s\n' "${_edid_data}" | md5sum | cut -d' ' -f1)"
        printf "%s %s\n" "${_product_hash}" "${_product_port}" 
    done
}

# map "<monitor hash>" "<port name>"
_monitor_to_port_map="$(_get_monitor_to_port_map)"

# always print available monitors
printf '%s\n' "Available monitors and ports:"
printf '%s\n' "${_monitor_to_port_map}" | sed 's/^/* /'

# on list mode just exit after print
[ "${_list_only}" -eq 1 ] && exit 0

# kill all conky instances
pkill -f conkyrc-kernel || true

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

_set_wallpaper_line_for_port() {
    _wallpaper_line="${1}"
    _wallpaper_port="${2}"
    _wallpaper_path="$(printf '%s\n' "${_rtl_wallpapers}" | sed -n "${_wallpaper_line}p")"
    if [ -n "${_wallpaper_path}" ]
    then
        printf 'Setting %s wallpaper to %s (%s)\n' "${_wallpaper_port}" "${_wallpaper_path}" "${_wallpaper_line}"
        xwallpaper --output "${_wallpaper_port}" --stretch "${_wallpaper_path}"
    else
        printf 'There are not enough wallpapers (%s) for %s\n' "${_wallpaper_line}" "${_wallpaper_port}"
    fi
}

_start_conky_on_index() {
    printf 'Starting conky on screen %s\n' "${1}"
    conky -q -d -c "${HOME}/arch/conky/conkyrc-kernel" --xinerama-head "${1}"
}

# iterate monitors right to left
# when using left to right mouse cursor is not visible on right monitor under hybrid graphics
_configure_screens() {
    # xrandr
    _previous_port=""
    _i=0
    for _monitor in ${_rtl_monitors}
    do
        _port="$(_get_port_for_monitor "${_monitor}")"
        if [ -n "${_port}" ]
        then
            _screen_info="$(_get_screen_info_for_port "${_port}")"
            _max_resolution="$(_get_max_resolution_for_screen_info "${_screen_info}")"
            _max_refresh_rate="$(_get_max_refresh_rate_for_screen_info "${_screen_info}")"
            
            set -- --output "${_port}" --mode "${_max_resolution}" --rate "${_max_refresh_rate}"

            if [ "${_monitor}" = "${_primary_monitor}" ]
            then
                set -- "${@}" --primary
            fi
            
            if [ -n "${_previous_port}" ]
            then
                set -- "${@}" --left-of "${_previous_port}"
            fi
            
            printf "(%s) xrandr %s\n" "${_monitor}" "${*}"
            xrandr "${@}"

            _previous_port="${_port}"
            _i=$((_i + 1))
        else
            printf '(%s) Monitor not found, skipping xrandr.\n' "${_monitor}"
        fi
    done
    
    _total_count="${_i}"
    
    # wallpapers
    _i=1
    for _monitor in ${_rtl_monitors}
    do
        _port="$(_get_port_for_monitor "${_monitor}")"
        if [ -n "${_port}" ]
        then
            printf '(%s) ' "${_monitor}"
            _set_wallpaper_line_for_port "${_i}" "${_port}"
            _i=$((_i + 1))
        else
            printf '(%s) Monitor not found, skipping wallpaper.\n' "${_monitor}"
        fi
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

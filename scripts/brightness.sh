#!/bin/sh

_exit() {
    printf '%s\n' "${1}"
    exit 1
}

if [ "$(id -u)" -ne 0 ]
then
    _exit "Must be run as root."
fi

_direction="${1}"
if [ "${_direction}" != "1" ] && [ "${_direction}" != "-1" ]
then
    _exit "Argument must be -1 or 1"
fi

_path=""
_nvidia="/sys/class/backlight/nvidia_0"
_intel="/sys/class/backlight/intel_backlight"

if [ -d "${_nvidia}" ]
then
    _path="${_nvidia}"
elif [ -d "${_intel}" ]
then
    _path="${_intel}"
else
    _exit "No supported backlight found."
fi

if [ ! -w "${_path}/brightness" ] || [ ! -r "${_path}/max_brightness" ]
then
    _exit "No supported backlight controls found."
fi

_current="$(cat "${_path}/brightness")"
_max="$(cat "${_path}/max_brightness")"

# already at max
if [ "${_direction}" = "1" ] && [ "${_current}" -eq "${_max}" ]
then
    _exit "Already at max."
fi

_num_steps="10"
_step="$(( _max / _num_steps ))"

# if max is less than num_steps set step to 1
[ "${_step}" -lt 1 ] && _step="1"

_next="$(( _current + (_step * _direction) ))"

# don't allow next to go 0 (black screen) or below
if [ "${_next}" -le 0 ]
then
    _exit "Brightness too low."
fi

# don't allow to go over max
[ "${_next}" -gt "${_max}" ] && _next="${_max}"

printf "Setting brightness to %s/%s\n" "${_next}" "${_max}"
printf '%s\n' "${_next}" > "${_path}/brightness"

#!/bin/bash
. "/home/igor/arch/scripts/_lib.sh"

set -eu
enable -f /usr/lib/bash/sleep sleep

_temp1=45
_temp2=80
_interval=10

_t1="$(( _temp1 * 1000 ))"
_t2="$(( _temp2 * 1000 ))"

_v1=50
_v2=255

_input_range="$(( _t2 - _t1 ))"
_output_range="$(( _v2 - _v1 ))"

_nvtype="$(grep -l TMEM /sys/devices/virtual/thermal/thermal_zone*/type)"
_nvpath="${_nvtype%/*}/temp"

_cpupath="/sys/devices/platform/coretemp.0/hwmon/hwmon5/temp1_input"
_fanctrl="/sys/devices/platform/asus-nb-wmi/hwmon/hwmon4/pwm1"

while true
do
    # cpu temp
    _input="$(<"${_cpupath}")"
    _nvtemp="$(<"${_nvpath}")"

    # if nvidia is hotter, use that temp
    if [ "${_nvtemp}" -gt "${_input}" ]
    then
        _echo "Using NVIDIA temp."
        _input="${_nvtemp}"
    fi

    _value="$(( (((_input - _t1) * _output_range) / _input_range) + _v1 ))"

    [ "${_value}" -lt "${_v1}" ] && _value="${_v1}"
    [ "${_value}" -gt "${_v2}" ] && _value="${_v2}"

    _echo "$(( _input / 1000 ))°C -> ${_value}"
    _echo "${_value}" > "${_fanctrl}"
    sleep "${_interval}"
done

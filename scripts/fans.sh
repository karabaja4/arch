#!/bin/sh

_echo() {
    printf '%s\n' "${1}"
}

_not_root() {
    _echo "Root privileges are required to run this command\n"
    exit 1
}

[ "$(id -u)" -ne 0 ] && _not_root

_temp1=40
_temp2=80
_interval=10

_t1="$(( _temp1 * 1000 ))"
_t2="$(( _temp2 * 1000 ))"

_v1=100
_v2=255

_input_range="$(( _t2 - _t1 ))"
_output_range="$(( _v2 - _v1 ))"

while true
do
    # cpu temp
    _input="$(cat /sys/devices/platform/coretemp.0/hwmon/hwmon5/temp1_input)"

    # if nvidia is hotter, use that temp
    _nvdir="$(dirname "$(grep -l TMEM /sys/devices/virtual/thermal/thermal_zone*/type)")"
    _nvtemp="$(cat "${_nvdir}/temp")"
    [ "${_nvtemp}" -gt "${_input}" ] && _input="${_nvtemp}"

    _value="$(( (((_input - _t1) * _output_range) / _input_range) + _v1 ))"

    [ "${_value}" -lt "${_v1}" ] && _value="${_v1}"
    [ "${_value}" -gt "${_v2}" ] && _value="${_v2}"

    _echo "$(( _input / 1000 ))°C -> ${_value}"
    printf '%s' "${_value}" > /sys/devices/platform/asus-nb-wmi/hwmon/hwmon4/pwm1
    sleep "${_interval}"
done

#!/bin/sh

_not_root() {
    printf "Root privileges are required to run this command\n"
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
    _input1="$(cat /sys/devices/platform/coretemp.0/hwmon/hwmon5/temp1_input)"
    _input2="$(cat /sys/devices/virtual/thermal/thermal_zone1/temp)"

    if [ "${_input2}" -gt "${_input1}" ]
    then
        _input1="${_input2}"
    fi

    _value="$(( (((_input1 - _t1) * _output_range) / _input_range) + _v1 ))"
    if [ "${_value}" -gt "255" ]
    then
        _value="255"
    fi

    printf '%s°C -> %s\n' "$(( _input1 / 1000 ))" "${_value}"
    printf '%s' "${_value}" > /sys/devices/platform/asus-nb-wmi/hwmon/hwmon4/pwm1
    sleep "${_interval}"
done

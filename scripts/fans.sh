#!/bin/bash
. "/home/igor/arch/scripts/_lib.sh"

set -u
enable -f /usr/lib/bash/sleep sleep

_threshold=70

_cpu_label="$(grep -l 'Package id 0' /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp*_label 2>/dev/null)"
_cpu_base="${_cpu_label%/*}"
_asus_label="$(grep -lw '^asus$' /sys/devices/platform/asus-nb-wmi/hwmon/hwmon*/name 2>/dev/null)"
_asus_base="${_asus_label%/*}"

_echo "CPU base is ${_cpu_base}"
_echo "ASUS base is ${_asus_base}"

_set_pwm() {
    _current_pwm="$(cat "${_asus_base}/pwm1_enable")"
    if [ "${_current_pwm}" != "${1}" ]
    then
        _echo "Setting PWM to ${1}"
        printf '%s' "${1}" > "${_asus_base}/pwm1_enable"
        printf '%s' "${1}" > "${_asus_base}/pwm2_enable"
        printf '%s' "${1}" > "${_asus_base}/pwm3_enable"
    else
        _echo "No change."
    fi
}

while true
do
    # nvidia temp
    _nv_temp="$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader)"
    
    # cpu temp
    _cpu_temp_full="$(cat "${_cpu_base}/temp1_input" 2>/dev/null)"
    _cpu_temp="${_cpu_temp_full:0:2}"
    
    _echo "NVIDIA: ${_nv_temp}"
    _echo "CPU: ${_cpu_temp}"
    
    if [ -n "${_nv_temp}" ] && [ -n "${_cpu_temp}" ]
    then
        if [ "${_nv_temp}" -gt "${_threshold}" ] || [ "${_cpu_temp}" -gt "${_threshold}" ]
        then
            _set_pwm 0
        else
            _set_pwm 2
        fi
    else
        _echo "Error reading temperatures"
        _set_pwm 0
    fi
    
    sleep 1
done

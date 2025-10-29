#!/bin/sh
set -eu

_lock="/tmp/suspend.lock"

if [ -f "${_lock}" ]
then
    printf '%s\n' "Lock file exists."
    exit 1
else
    touch "${_lock}"
fi

sync

_toggle_wakeup() {
    printf '%s\n' "${1}" > /proc/acpi/wakeup
}

_nvidia() {
    if [ -x "/usr/bin/nvidia-sleep.sh" ]
    then
        /usr/bin/nvidia-sleep.sh "${1}"
    fi
}

_toggle_wakeup "TXHC"
_toggle_wakeup "XHCI"

_nvidia "suspend"

printf '%s\n' "deep" > /sys/power/mem_sleep
printf '%s\n' "mem" > /sys/power/state

_nvidia "resume"

_toggle_wakeup "XHCI"
_toggle_wakeup "TXHC"

rm "${_lock}"

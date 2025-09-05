#!/bin/sh
set -eu

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

_toggle_wakeup "TXHC"
_toggle_wakeup "XHCI"

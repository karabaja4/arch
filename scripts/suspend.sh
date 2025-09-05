#!/bin/sh
set -eu

sync

printf '%s\n' "TXHC" > /proc/acpi/wakeup

if [ -x "/usr/bin/nvidia-sleep.sh" ]
then
    /usr/bin/nvidia-sleep.sh suspend
fi

printf '%s\n' "deep" > /sys/power/mem_sleep
printf '%s\n' "mem" > /sys/power/state

if [ -x "/usr/bin/nvidia-sleep.sh" ]
then
    /usr/bin/nvidia-sleep.sh resume
fi

printf '%s\n' "TXHC" > /proc/acpi/wakeup

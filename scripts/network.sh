#!/bin/sh

_interface="enp2s0"

ip link set "${_interface}" up
exec /usr/bin/busybox udhcpc -nRfv -s "/home/igor/arch/udhcpc/default.script" -i "${_interface}"
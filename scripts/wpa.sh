#!/bin/bash

killall wpa_supplicant
killall dhcpcd
sleep 1

declare iface="iface"
declare ssid="ssid"
declare psk="psk"

declare file="/tmp/wifi.conf"
declare conf="network={
    ssid=\"$ssid\"
    psk=\"$psk\"
}"

echo -e "$conf" > $file

wpa_supplicant -B -i $iface -c $file
sleep 1
dhcpcd $iface

wpa_supplicant -B -i ra0 -c /etc/wpa_supplicant/batak.conf
sleep 1
dhcpcd ra0

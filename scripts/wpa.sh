wpa_supplicant -B -i wlp0s20u1u1 -c /etc/wpa_supplicant/batak.conf
sleep 1
dhcpcd wlp0s20u1u1

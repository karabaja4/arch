#!/bin/sh
set -eu

_source='wwp0s20f0u6i12'
_ap='wlp58s0'
_root='/tmp/softap'

_secret='/etc/secret/secret.json'
_password="$(jq -crM '.wifi.password' "${_secret}")"

mkdir -p "${_root}"

# MAC
rfkill unblock wifi
macchanger --mac=00:0B:AD:C0:FF:EE "${_ap}"
ip link set "${_ap}" up

# ROUTING
iptables -t nat -I POSTROUTING -o "${_source}" -j MASQUERADE

iptables -I FORWARD -i "${_source}" -o "${_ap}" -j ACCEPT
iptables -I FORWARD -i "${_ap}" -o "${_source}" -j ACCEPT

ip link set up dev "${_ap}"
ip addr add 20.0.0.1/24 broadcast 20.0.0.255 dev "${_ap}"

printf '%s\n' '1' > /proc/sys/net/ipv4/ip_forward

# DHCP
cat << EOF > "${_root}/dnsmasq.conf"
no-resolv
bind-interfaces
interface=${_ap}
dhcp-range=20.0.0.100,20.0.0.254,24h
server=1.1.1.1
server=1.0.0.1
EOF

# https://github.com/morrownr/USB-WiFi/blob/main/home/AP_Mode/hostapd-WiFi6.conf
cat << EOF > "${_root}/hostapd.conf"
interface=${_ap}
driver=nl80211

ssid=Thinkpad5G

hw_mode=a
channel=36
country_code=HR
ieee80211d=1

wmm_enabled=1

ieee80211n=1
ht_capab=[LDPC][HT40+][HT40-][GF][SHORT-GI-20][SHORT-GI-40][TX-STBC][RX-STBC1][MAX-AMSDU-7935]

ieee80211ac=1
vht_oper_chwidth=1
vht_oper_centr_freq_seg0_idx=42
vht_capab=[MAX-MPDU-11454][RXLDPC][SHORT-GI-80][TX-STBC-2BY1][SU-BEAMFORMEE][MU-BEAMFORMEE][RX-ANTENNA-PATTERN][TX-ANTENNA-PATTERN][RX-STBC-1][BF-ANTENNA-4][MAX-A-MPDU-LEN-EXP7]

ieee80211ax=1
he_oper_chwidth=1
he_oper_centr_freq_seg0_idx=42

max_num_sta=16
auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
wpa_passphrase=${_password}
EOF

dnsmasq -C "${_root}/dnsmasq.conf"
( hostapd "${_root}/hostapd.conf" & ) > /dev/null 2>&1

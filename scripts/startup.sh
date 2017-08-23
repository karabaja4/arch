#!/bin/bash

wireless="ra0"
ethernet="eth0"
softap="ath0"

#exit 0
sleep 15

# iskljuciti led na ath0
#echo none > /sys/class/leds/ath9k_htc-phy*/trigger

# entropy
haveged -w 1024
sleep 1

# MAC
macchanger -r $wireless
macchanger -r $softap
macchanger -r $ethernet

# ROUTING
iptables -t nat -I POSTROUTING -o $wireless -j MASQUERADE

iptables -I FORWARD -i $wireless -o $ethernet -j ACCEPT
iptables -I FORWARD -i $ethernet -o $wireless -j ACCEPT

iptables -I FORWARD -i $wireless -o $softap -j ACCEPT
iptables -I FORWARD -i $softap -o $wireless -j ACCEPT

ip link set up dev $ethernet
ip addr add 10.0.0.1/24 broadcast 10.0.0.255 dev $ethernet

ip link set up dev $softap
ip addr add 20.0.0.1/24 broadcast 20.0.0.255 dev $softap

echo 1 > /proc/sys/net/ipv4/ip_forward

# DHCP
cat << EOF > /root/dnsmasq.conf
no-resolv
interface=$ethernet
interface=$softap
dhcp-range=interface:$ethernet,10.0.0.100,10.0.0.254,24h
dhcp-range=interface:$softap,20.0.0.100,20.0.0.254,24h
server=8.8.8.8
server=8.8.4.4
EOF

# 802.11n HT20
# ieee80211n=1
# wmm_enabled=1
# ht_capab=[HT20][SHORT-GI-20][RX-STBC1]

# AP
cat << EOF > /root/hostapd.conf
ssid=HelloWorld
interface=$softap
driver=nl80211
hw_mode=g
#ieee80211n=1
#wmm_enabled=1
#ht_capab=[RX-STBC1]
channel=1
wpa=2
wpa_passphrase=password123456
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
EOF

# RDP
#iptables -t nat -A PREROUTING -p tcp --dport 3389 -j DNAT --to-destination 10.0.0.161:3389

# resolv
cat << EOF > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

dnsmasq -C /root/dnsmasq.conf
hostapd /root/hostapd.conf
sleep infinity

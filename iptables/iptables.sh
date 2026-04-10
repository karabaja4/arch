#!/bin/sh

# Clear all existing rules in all chains
iptables -F

# Delete all user-defined chains
iptables -X

# Set default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow established and related connections
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Allow all traffic on the loopback interface
iptables -A INPUT -i lo -j ACCEPT

# Allow DHCP on wifi (dnsmasq)
iptables -A INPUT -i wlp58s0 -p udp --dport 67 -j ACCEPT

# Allow DNS on wifi (dnsmasq)
iptables -A INPUT -i wlp58s0 -p udp --dport 53 -j ACCEPT
iptables -A INPUT -i wlp58s0 -p tcp --dport 53 -j ACCEPT

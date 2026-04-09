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

# Allow all traffic on wifi
iptables -A INPUT -i wlp58s0 -j ACCEPT


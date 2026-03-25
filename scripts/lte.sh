#!/bin/sh
set -eu

# EM7455

_dev="/dev/cdc-wdm0"
_iface="wwp0s20f0u6i12"

_qmicli() {
    qmicli --device-open-proxy --device="${_dev}" "${@}"
}

# unblock FCC, persists across reboots but not shutdowns
_qmicli --dms-set-fcc-authentication || true

_qmicli --dms-set-operating-mode='online'
_qmicli --wds-start-network='3gpp-profile=1' --client-no-release-cid

_settings="$(_qmicli --wds-get-current-settings)"

_parse() {
    printf '%s\n' "${_settings}" | grep "${1}" | awk '{print $NF}'
}

_get_prefix() {
    ipcalc "${1}" "${2}" | grep 'Netmask' | awk '{print $4}'
}

_ip="$(_parse 'IPv4 address')"
_mask="$(_parse 'IPv4 subnet mask')"
_gateway="$(_parse 'IPv4 gateway address')"
_dns1="$(_parse 'IPv4 primary DNS')"
_dns2="$(_parse 'IPv4 secondary DNS')"

_prefix="$(_get_prefix "${_ip}" "${_mask}")"

ip link set "${_iface}" up
ip addr add "${_ip}/${_prefix}" dev "${_iface}"
ip route add default dev "${_iface}"
printf 'nameserver %s\nnameserver %s\n' "${_dns1}" "${_dns2}" > /etc/resolv.conf

printf 'Connected.\nIP: %s\nGateway: %s\nDNS1: %s\nDNS2: %s\n' "${_ip}" "${_gateway}" "${_dns1}" "${_dns2}"

# $ qmicli --device-open-proxy --device=/dev/cdc-wdm0 --wds-get-profile-list="3gpp"
# Profile list retrieved:
# 	[1] 3gpp - 
# 		APN: 'internet.ht.hr'
# 		PDP type: 'ipv4'
# 		PDP context number: '1'
# 		Username: ''
# 		Password: ''
# 		Auth: 'none'
# 		No roaming: 'no'
# 		APN disabled: 'no'
#
# qmicli --device-open-proxy --device=/dev/cdc-wdm0 \
#   --wds-create-profile="3gpp,apn=internet.ht.hr,pdp-type=IP,auth=none"

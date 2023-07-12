#!/bin/sh
set -eu
IFS='
'

_echo() {
    printf '%s\n' "${1}"
}

_prompt() {
    printf '%s' "${1}"
}

_not_root() {
    _echo "Not root"
    exit 1
}

[ "$(id -u)" -ne 0 ] && _not_root

_invalid_input() {
    _echo "Invalid input"
    exit 2
}

_multiple_users() {
    _echo "Cannot find a single logged in user"
    exit 3
}

# get logged in user info
_user="$(users)"
_usercount="$(_echo "${_user}" | wc -w)"
[ "${_usercount}" -ne 1 ] && _multiple_users
_homedir="$(getent passwd "${_user}" | cut -d':' -f6)"

_interface="wlp0s20u2u2u4"
ip link set "${_interface}" up

# scan for networks and present a choice
_echo "Scanning for networks..."
_essids="$(iwlist "${_interface}" scan | grep 'ESSID' | cut -d'"' -f2)"
_i=1
for _essid in ${_essids}
do
    _echo "${_i}) ${_essid}"
    _i=$((_i+1))
done

# read a choice and save
_prompt "Select network: "
read -r _idx
_selected_essid="$(_echo "${_essids}" | sed -n "${_idx}p")"
[ -z "${_selected_essid}" ] && _invalid_input
_md5="$(_echo "${_selected_essid}" | md5sum | cut -d' ' -f1)"
_echo "Selected: ${_selected_essid} (md5: ${_md5})"

# config paths
_config_dir="${_homedir}/.config/wifi"
mkdir -p "${_config_dir}"
_config="${_config_dir}/${_md5}.conf"

# if config does not exist, create it
if [ ! -f "${_config}" ]
then
    _prompt "Enter password: "
    read -r _password
    _echo "Saving config ${_config}"
    printf '%s\n%s\n%s\n%s\n%s\n' \
        "ctrl_interface=/run/wpa_supplicant" \
        "network={" \
        "    ssid=\"${_selected_essid}\"" \
        "    psk=\"${_password}\"" \
        "}" > "${_config}"
else
    _echo "Using config ${_config}"
fi

# run with setsid to prevent terminal sending sigint to children
setsid wpa_supplicant -c "${_config}" -i "${_interface}" &
_pid1="${!}"

setsid dhcpcd -4 -B "${_interface}" &
_pid2="${!}"

# kill all on exit
_trap() {
    _echo "killing ${_pid1} ${_pid2}"
    kill -TERM "${_pid1}" "${_pid2}"
    ip link set "${_interface}" down
    _echo "Goodbye"
}

trap '_trap' INT TERM QUIT HUP

wait

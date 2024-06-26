#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"

set -eu

_usage() {
    _echo "Connect to a WiFi network." \
          "Usage: $(basename "${0}") [interface (omit to autodetect)]"
    exit 1
}

case "${_arg1}" in
--help|-h)
    _usage
    ;;
esac

_log() {
    _color_echo 94 "${1}"
}

_must_be_root

_is_running() {
    if pgrep -x "${1}" > /dev/null
    then
        _err 100 "${1} is running, cannot continue."
    fi
}

_is_running 'wpa_supplicant'
_is_running 'dhcpcd'

# resolve interface
_interface="$(printf '%s\n' /sys/class/net/*/wireless | cut -d/ -f5 | grep -v -F '*' | cat)"
if [ -z "${_interface}" ]
then
    _err 101 "No wireless interfaces found."
fi

if [ -z "${_arg1}" ]
then
    # no argument given, autodetect interface
    _count="$(_nelc "${_interface}")"
    if [ "${_count}" -ne 1 ]
    then
        _err 102 "More than one interface found:" \
                 "${_interface}" \
                 "Please specify an interface as an argument." >&2
    else
        _log "Detected interface ${_interface}"
    fi
else
    # interface provided by user on arg1
    _match="$(_echo "${_interface}" | grep -F "${_arg1}" | cat)"
    if [ -z "${_match}" ]
    then
        _err 103 "Interface ${_arg1} not found."
    else
         _interface="${_match}"
        _log "Using interface ${_interface}"
    fi
fi

ip link set "${_interface}" up

# scan for networks and present a choice
_log "Scanning for networks..."
_essids="$(iwlist "${_interface}" scan | grep -F 'ESSID' | cut -d'"' -f2)"
_i=1

if [ -z "${_essids}" ]
then
    _err 104 "No networks found."
fi

for _essid in ${_essids}
do
    _echo "${_i}) ${_essid}"
    _i=$((_i+1))
done

_prompt() {
    printf '%s' "${1}"
}

_invalid_input() {
    _err 105 "Invalid input."
}

# read a choice
_prompt "Select network: "
read -r _idx

# check empty input
[ -z "${_idx}" ] && _invalid_input

# check if there are non-numbers in input
_idx_validate="$(_echo "${_idx}" | tr -d '0-9')"
[ -n "${_idx_validate}" ] && _invalid_input

# check the number is in range
_ssid="$(_echo "${_essids}" | sed -n "${_idx}p")"
[ -z "${_ssid}" ] && _invalid_input

_md5="$(_echo "${_ssid}" | md5sum | cut -d' ' -f1)"
_log "Selected: ${_ssid} (md5: ${_md5})"

# config paths
_config_dir="/root/.config/wifi"
mkdir -p "${_config_dir}"
_config="${_config_dir}/${_md5}.conf"

# if config does not exist, create it
if [ ! -f "${_config}" ]
then
    _prompt "Enter password: "
    read -r _psk
    _log "Saving config ${_config}"
    printf '%s\n%s\n%s\n%s\n%s\n' \
        "ctrl_interface=/run/wpa_supplicant" \
        "network={" \
        "    ssid=\"${_ssid}\"" \
        "    psk=\"${_psk}\"" \
        "}" > "${_config}"
else
    _log "Using config ${_config}"
fi

# run with setsid to prevent terminal sending sigint to children
setsid wpa_supplicant -c "${_config}" -i "${_interface}" &
_pid1="${!}"

setsid dhcpcd -4 -B "${_interface}" &
_pid2="${!}"

# kill all on exit
_trap() {
    _log "killing ${_pid1} ${_pid2}"
    kill -TERM "${_pid1}" "${_pid2}"
}

trap '_trap' INT TERM QUIT HUP

_log "All components initialized."

# sleep is the catch for SIGINT
# better than interrupting wait, which if killed
# ends the script before the children had the chance
# to exit and print the closing text to stdout
/bin/sleep infinity || true

# wait exists with non zero on SIGINT so mask it
_log "Waiting for child processes to exit..."
wait || true
_log "All children exited."

# bring interface down
ip link set "${_interface}" down
_log "Interface ${_interface} down."

_log "Goodbye."

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

# setup hook
_log "Setting up hook..."
ln -sf /usr/share/dhcpcd/hooks/10-wpa_supplicant /usr/lib/dhcpcd/dhcpcd-hooks/

# scar 18 wifi needs reset after each scan
ip link set "${_interface}" down
ip link set "${_interface}" up

# scan for networks and present a choice
_log "Scanning for networks..."
_essids="$(iwlist "${_interface}" scan | grep -F 'ESSID' -B 5 | cut -c 11-)"

if [ -z "${_essids}" ]
then
    _err 104 "No networks found."
fi

_echo "${_essids}"

# loop until user enters a valid choice (non-empty, at least two digits, starting with Cell)
_idx=''
while [ -z "${_idx}" ] || ! _echo "${_idx}" | grep -Eq '^[0-9]{2,}$' || ! _echo "${_essids}" | grep -Eq "^Cell ${_idx} - "
do
    printf '%s' 'Select a network: '
    read -r _idx
done

# extract selected cell
_cell="$(_echo "${_essids}" | grep -E "^Cell ${_idx} - " -A 5)"

# bssid
_bssid="$(_echo "${_cell}" | grep -o 'Address: [0-9A-F:]\{17\}' | cut -d' ' -f2)"
if [ -z "${_bssid}" ]
then
    _err 105 'Cannot parse BSSID.'
fi

# essid
_essid="$(_echo "${_cell}" | tail -n 1 | grep 'ESSID:' | cut -d'"' -f2)"
if [ -z "${_essid}" ]
then
    _err 106 'Cannot parse ESSID.'
fi

_log "ESSID: ${_essid}, BSSID: ${_bssid}"

# config paths
_config_dir="/root/.config/wifi"
mkdir -p "${_config_dir}"
_config="${_config_dir}/$(_echo "${_bssid}" | tr -d ':').conf"

# if config does not exist, create it
if [ ! -f "${_config}" ]
then
    printf '%s' "Enter a password: "
    read -r _psk
    _log "Saving config to ${_config}"
    printf '%s\n%s\n%s\n%s\n%s\n%s\n' \
        "ctrl_interface=/run/wpa_supplicant" \
        "network={" \
        "    bssid=${_bssid}" \
        "    ssid=\"${_essid}\"" \
        "    psk=\"${_psk}\"" \
        "}" > "${_config}"
else
    _log "Using config ${_config}"
fi

_wpa_supplicant_conf='/etc/wpa_supplicant/wpa_supplicant.conf'
_log "Copying ${_config} to ${_wpa_supplicant_conf}"
cp "${_config}" "${_wpa_supplicant_conf}"

# run dhcpcd which will implicitly run wpa_supplicant using a hook
dhcpcd -4 "${_interface}"

#!/bin/sh

set -eu

# helper functions start
_echo() {
    for _line in "${@}"
    do
        printf '%s\n' "${_line}"
    done
}

_color_echo() {
    _color_code="${1}"
    shift
    for _color_line in "${@}"
    do
        printf '\033[%sm%s\033[0m\n' "${_color_code}" "${_color_line}"
    done
}

_err() {
    _color_echo 91 "${@}" >&2
    exit 2
}

_log() {
    _color_echo 94 "${@}"
}

_nelc() {
    _echo "${@}" | grep -c -v '^[[:space:]]*$'
}

_must_be_root() {
    if [ "$(id -u)" -ne 0 ]
    then
        _err "Root privileges are required to run this command."
    fi
}

_must_not_run() {
    if pgrep -x "${1}" > /dev/null
    then
        _err "${1} is running, cannot continue."
    fi
}
# helper functions end

_usage() {
    _echo "Connect to a WiFi network." \
          "Usage: $(basename "${0}") [interface (omit to autodetect)]"
    exit 1
}

_arg1="${1-}"

case "${_arg1}" in
--help|-h)
    _usage
    ;;
esac

_must_be_root
_must_not_run 'wpa_supplicant'
_must_not_run 'udhcpc'

# resolve interface
_interface="$(_echo /sys/class/net/*/wireless | cut -d/ -f5 | grep -v -F '*' || true)"
if [ -z "${_interface}" ]
then
    _err "No wireless interfaces found."
fi

if [ -z "${_arg1}" ]
then
    # no argument given, autodetect interface
    _count="$(_nelc "${_interface}")"
    if [ "${_count}" -ne 1 ]
    then
        _err "More than one interface found:" \
             "${_interface}" \
             "Please specify an interface as an argument."
    else
        _log "Detected interface ${_interface}"
    fi
else
    # interface provided by user on arg1
    _match="$(_echo "${_interface}" | grep -Fx "${_arg1}" || true)"
    if [ -z "${_match}" ]
    then
        _err "Interface ${_arg1} not found."
    else
         _interface="${_match}"
        _log "Using interface ${_interface}"
    fi
fi

_resolv_conf="/etc/resolv.conf"
_resolv_conf_old="/etc/resolv.conf.old"

# backup resolv.conf so dhcpcd does not overwrite it
_log "Backing up ${_resolv_conf} to ${_resolv_conf_old}"
cp "${_resolv_conf}" "${_resolv_conf_old}"

# lenovo ideapad 3 needs this
rfkill unblock wifi

# scar 18 wifi needs reset after each scan
ip link set "${_interface}" down
ip link set "${_interface}" up

# start wpa_supplicant for scanning purposes
_scan_pid_file="/run/wpa_supplicant/${_interface}-scan.pid"
wpa_supplicant -B -i "${_interface}" -c /dev/null -C /run/wpa_supplicant -P "${_scan_pid_file}" > /dev/null
sleep 1
_scan_pid="$(cat "${_scan_pid_file}")"

# scan networks
wpa_cli -i "${_interface}" scan > /dev/null

# allow for scan to complete
_log "Scanning for networks..."
sleep 5

# save scan results
_scan_results="$(wpa_cli -i "${_interface}" scan_results | sed '1d')"
if [ -z "${_scan_results}" ]
then
    _err "No networks found."
fi

# kill wpa_supplicant because we are done scanning
kill "${_scan_pid}"

# enumerate choices and show them
# loop until the user enters a correct choice
_choices="$(_echo "${_scan_results}" | nl -w1 -s ') ')"
_echo "${_choices}"
_ln=''
while [ -z "${_ln}" ] || ! _echo "${_choices}" | grep -q "^${_ln}) "
do
    printf 'Choose a network: '
    read -r _ln
done

# parse out the choice
_selected_choice="$(_echo "${_scan_results}" | sed -n "${_ln}p")"
_bssid="$(_echo "${_selected_choice}" | cut -f1)"
_essid="$(_echo "${_selected_choice}" | cut -f5-)"

# print the choice
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

wpa_supplicant -B -i "${_interface}" -c "${_config}"
sleep 3
udhcpc -nqfv -i "${_interface}"

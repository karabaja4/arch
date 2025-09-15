#!/bin/sh
. "$(dirname "$(readlink -f "${0}")")/_lib.sh"

_usage() {
    _script_name="$(basename "${0}")"
    _echo "Connect to a WiFi network." \
          "Usage:" \
          "${_script_name} [interface (omit to autodetect)]" \
          "${_script_name} [off|stop]"
    exit 1
}

case "${_arg1}" in
--help|-h)
    _usage
    ;;
off|stop)
    wpa_cli terminate
    exit 0
    ;;
esac

_must_be_root
_must_not_run 'wpa_supplicant'
_must_not_run 'udhcpc'

# resolve interface
_interface="$(_echo /sys/class/net/*/wireless | cut -d/ -f5 | grep -v -F '*')"
if [ -z "${_interface}" ]
then
    _fatal "No wireless interfaces found."
fi

if [ -z "${_arg1}" ]
then
    # no argument given, autodetect interface
    _count="$(_nelc "${_interface}")"
    if [ "${_count}" -ne 1 ]
    then
        _fatal "More than one interface found:" \
               "${_interface}" \
               "Please specify an interface as an argument."
    else
        _info "Detected interface ${_interface}"
    fi
else
    # interface provided by user on arg1
    _match="$(_echo "${_interface}" | grep -Fx "${_arg1}")"
    if [ -z "${_match}" ]
    then
        _fatal "Interface ${_arg1} not found."
    else
         _interface="${_match}"
        _info "Using interface ${_interface}"
    fi
fi

_resolv_conf="/etc/resolv.conf"
_resolv_conf_old="/etc/resolv.conf.old"

# backup resolv.conf so dhcpcd does not overwrite it
_info "Backing up ${_resolv_conf} to ${_resolv_conf_old}"
cp "${_resolv_conf}" "${_resolv_conf_old}"

# lenovo ideapad 3 needs this
rfkill unblock wifi

# scar 18 wifi needs reset after each scan
ip link set "${_interface}" down
ip link set "${_interface}" up

# start wpa_supplicant for scanning purposes
wpa_supplicant -B -i "${_interface}" -c /dev/null -C /run/wpa_supplicant > /dev/null
sleep 1

# scan networks
wpa_cli -i "${_interface}" scan > /dev/null

# allow for scan to complete
_info "Scanning for networks..."
sleep 5

# save scan results
_scan_results="$(wpa_cli -i "${_interface}" scan_results | sed '1d')"

# kill wpa_supplicant because we are done scanning
wpa_cli -i "${_interface}" terminate > /dev/null

if [ -z "${_scan_results}" ]
then
    _fatal "No networks found."
fi

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
_info "ESSID: ${_essid}, BSSID: ${_bssid}"

# config paths
_config_dir="/root/.config/wifi"
mkdir -p "${_config_dir}"
_config="${_config_dir}/$(_echo "${_bssid}" | tr -d ':').conf"

# if config does not exist, create it
if [ ! -f "${_config}" ]
then
    _psk=''
    while [ -z "${_psk}" ]
    do
        printf '%s' "Enter a password ('-' for no password): "
        read -r _psk
    done
    _info "Saving config to ${_config}"
    {
        printf '%s\n' "ctrl_interface=/run/wpa_supplicant"
        printf '%s\n' "network={"
        printf '    bssid=%s\n' "${_bssid}"
        printf '    ssid="%s"\n' "${_essid}"
        if [ "${_psk}" != "-" ]
        then
            printf '    psk="%s"\n' "${_psk}"
        else
            printf '    %s\n' "key_mgmt=NONE"
        fi
        printf '%s\n' "}"
    } > "${_config}"
else
    _info "Using config ${_config}"
fi

wpa_supplicant -B -i "${_interface}" -c "${_config}"
sleep 3
udhcpc -nqfv -i "${_interface}"

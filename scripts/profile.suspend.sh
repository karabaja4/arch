#!/bin/sh

_user="$(id -un 1000)"

_tmp_config="/tmp/config-${_user}"
_user_config="/home/${_user}/.config"

# ${1} -> process
# ${2} -> directory
_profile_backup() {
    /usr/bin/kill --verbose --signal TERM --timeout 10000 KILL "${1}" 2>/dev/null
    if [ -d "${_tmp_config}/${2}" ] && [ -n "$(ls -A "${_tmp_config}/${2}")" ]
    then
        _tar="${_user_config}/${2}.tar"
        printf '%s\n' "Backing up to ${_tar}"
        tar cf "${_tar}" -C "${_tmp_config}" "${2}"
        chown "${_user}:${_user}" "${_tar}"
    fi
}

# backup profiles
_profile_backup "chromium" "chromium"
_profile_backup "code" "Code"
_profile_backup "azuredatastudio" "azuredatastudio"
_profile_backup "Discord" "discord"

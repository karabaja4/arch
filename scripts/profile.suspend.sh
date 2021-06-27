#!/bin/sh

if [ "$(id -u)" -eq 0 ]
then
    printf '%s\n' "This script needs to be run as a non-root user."
    exit 1
fi

_user="$(id -un)"
printf '%s\n' "Suspending profile (${_user})"

_tmp_config="/tmp/config-${_user}"
_user_config="/home/${_user}/.config"

# ${1} -> process
# ${2} -> directory
_profile_backup() {
    /usr/bin/kill --verbose --signal TERM --timeout 10000 KILL "${1}" 2>/dev/null
    _dir="${_tmp_config}/${2}"
    if [ -d "${_dir}" ] && [ -n "$(ls -A "${_dir}")" ]
    then
        _tar="${_user_config}/${2}.tar"
        printf '%s\n' "Backing up to ${_tar}"
        tar cf "${_tar}" -C "${_tmp_config}" "${2}"
    else
        printf '%s\n' "${_dir} is empty or does not exist"
    fi
}

# backup profiles
_profile_backup "chromium" "chromium"
_profile_backup "code" "Code"
_profile_backup "azuredatastudio" "azuredatastudio"
_profile_backup "Discord" "discord"

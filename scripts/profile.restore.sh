#!/bin/sh

if [ "$(id -u)" -eq 0 ]
then
    printf '%s\n' "This script needs to be run as a non-root user."
    exit 1
fi

_user="$(id -un)"
printf '%s\n' "Restoring profile (${_user})"

_tmp_config="/tmp/config-${_user}"
_tmp_cache="/tmp/cache-${_user}"

_user_config="/home/${_user}/.config"
_user_cache="/home/${_user}/.cache"

rm -rf "${_tmp_config}"
rm -rf "${_tmp_cache}"

mkdir "${_tmp_config}"
mkdir "${_tmp_cache}"

rm -rf "${_user_cache}"
ln -snfT "${_tmp_cache}" "${_user_cache}"

_link_config_dir() {
    
    _tmp_child="${_tmp_config}/${1}"
    _user_child="${_user_config}/${1}"

    mkdir "${_tmp_child}"
    rm -rf "${_user_child}"
    ln -snfT "${_tmp_child}" "${_user_child}"
}

# non-persistant
_link_config_dir "Slack"
_link_config_dir "Microsoft"
_link_config_dir "Microsoft Teams - Preview"
_link_config_dir "teams"
_link_config_dir "Postman"

# persistant
_link_config_dir "chromium"
_link_config_dir "Code"
_link_config_dir "azuredatastudio"
_link_config_dir "discord"

# ${1} -> tar name
_restore_profile() {
    _tar="${_user_config}/${1}.tar"
    if [ -f "${_tar}" ]
    then
        printf '%s\n' "Restoring ${_tar}"
        tar xf "${_tar}" -C "${_tmp_config}"
    else
        printf '%s\n' "${_tar} does not exist"
    fi
}

# restore profiles
_restore_profile "chromium"
_restore_profile "Code"
_restore_profile "azuredatastudio"
_restore_profile "discord"

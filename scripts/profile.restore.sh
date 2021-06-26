#!/bin/sh

_user="$(id -un 1000)"

_tmp_config="/tmp/config-${_user}"
_tmp_cache="/tmp/cache-${_user}"

_user_config="/home/${_user}/.config"
_user_cache="/home/${_user}/.cache"

mkdir "${_tmp_config}"
mkdir "${_tmp_cache}"

chown "${_user}:${_user}" "${_tmp_config}"
chown "${_user}:${_user}" "${_tmp_cache}"

rm -rf "${_user_cache}"
ln -sf "${_tmp_cache}" "${_user_cache}"
chown -h "${_user}:${_user}" "${_user_cache}"

_link_config_dir() {
    # create temp config dir
    mkdir "${_tmp_config}/${1}"
    chown "${_user}:${_user}" "${_tmp_config}/${1}"
    # link temp config dir to user config dir
    rm -rf "${_user_config:?}/${1}"
    ln -sf "${_tmp_config}/${1}" "${_user_config}/${1}"
    chown -h "${_user}:${_user}" "${_user_config}/${1}"
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
    if [ -f "${_user_config}/${1}.tar" ]
    then
        printf '%s\n' "Restoring ${_user_config}/${1}.tar"
        tar xf "${_user_config}/${1}.tar" -C "${_tmp_config}"
    fi
}

# restore profiles
_restore_profile "chromium"
_restore_profile "Code"
_restore_profile "azuredatastudio"
_restore_profile "discord"

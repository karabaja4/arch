#!/bin/sh

if [ "$(id -u)" -eq 0 ]
then
    printf '%s\n' "This script needs to be run as a non-root user."
    exit 1
fi

_user="$(id -un)"
printf '%s\n' "Symlinking temporary config dirs (${_user})"

_tmp_config="/tmp/xdg-${_user}/config"
_tmp_cache="/tmp/xdg-${_user}/cache"

_user_config="/home/${_user}/.config"
_user_cache="/home/${_user}/.cache"

rm -rf "${_tmp_config}"
rm -rf "${_tmp_cache}"

mkdir "${_tmp_config}"
mkdir "${_tmp_cache}"

rm -rf "${_user_cache}"
ln -sfT "${_tmp_cache}" "${_user_cache}"

_link_config_dir() {
    
    _tmp_child="${_tmp_config}/${1}"
    _user_child="${_user_config}/${1}"

    mkdir "${_tmp_child}"
    rm -rf "${_user_child}"
    ln -sfT "${_tmp_child}" "${_user_child}"
}

_link_config_dir "Microsoft"
_link_config_dir "Microsoft Teams - Preview"
_link_config_dir "Postman"
#_link_config_dir "Slack"
_link_config_dir "discord"
_link_config_dir "teams"

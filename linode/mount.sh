#!/bin/sh
set -eu

_user="igor"
_uid="$(id -u "${_user}")"
_gid="$(id -g "${_user}")"

_mount() {
    mount -t cifs -o credentials=/etc/smbcredentials/linode.cred,uid="${_uid}",gid="${_gid}",dir_mode=0755,file_mode=0644,serverino,nosharesock,actimeo=30 "${@}"
}

_mount "//linode.file.core.windows.net/public1" "/var/www/_public"
_mount "//linode.file.core.windows.net/private1" "/home/${_user}/_private"

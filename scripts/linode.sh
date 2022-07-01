#!/bin/sh
set -eu

_uid="$(id -u)"
_gid="$(id -g)"

_linode() {
    _user="$(jq -crM '.linode.username' "${HOME}/arch/secret.json")"
    _pass="$(jq -crM '.linode.password' "${HOME}/arch/secret.json")"
    doas mount -t cifs -o username="${_user}",password="${_pass}",uid="${_uid}",gid="${_gid}",dir_mode=0755,file_mode=0644,port=44555 "${@}"
}

mkdir -p "${HOME}/_public"
mkdir -p "${HOME}/_private"

_linode "//avacyn.aerium.hr/public" "${HOME}/_public"
_linode "//avacyn.aerium.hr/private" "${HOME}/_private"

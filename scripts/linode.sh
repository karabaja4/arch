#!/bin/sh

_mount() {
    _user="$(jq -crM '.linode.samba.username' "${HOME}/arch/secret.json")"
    _pass="$(jq -crM '.linode.samba.password' "${HOME}/arch/secret.json")"
    doas mount -t cifs -o username="${_user}",password="${_pass}",uid="$(id -u)",gid="$(id -g)" "${@}"
}

mkdir -p "${HOME}/_public"
mkdir -p "${HOME}/_private"
_mount "//avacyn.aerium.hr/public" "${HOME}/_public"
_mount "//avacyn.aerium.hr/private" "${HOME}/_private"
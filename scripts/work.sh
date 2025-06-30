#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"

set -eu

_secret="/etc/secret/secret.json"

_domain="$(jq -crM '.work.domain' "${_secret}")"
_host="$(jq -crM '.work.host' "${_secret}")"
_user="$(jq -crM '.work.user' "${_secret}")"
_password="$(jq -crM '.work.password' "${_secret}")"

_color_echo 31 "Connecting to: ${_user} @ ${_domain}/${_host}"
exec xfreerdp /monitors:0 /cert-ignore /bpp:32 /network:lan /audio-mode:2 /scale:100 /multimon /floatbar:sticky:off /gfx:RFX -themes -wallpaper -grab-keyboard \
/d:"${_domain}" \
/v:"${_host}" \
/u:"${_user}" \
/p:"${_password}"

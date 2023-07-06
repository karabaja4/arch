#!/bin/sh
set -eu

_echo() {
    printf "$(tput setaf 1)%s$(tput sgr0)\n" "${1}"
}

_secret="${HOME}/arch/secret.json"

_domain="$(jq -crM '.work.domain' "${_secret}")"
_host="$(jq -crM '.work.host' "${_secret}")"
_user="$(jq -crM '.work.user' "${_secret}")"
_password="$(jq -crM '.work.password' "${_secret}")"

_echo "Connecting to: ${_user} @ ${_domain}/${_host}"
exec xfreerdp /monitors:0 /cert-ignore /bpp:32 /network:lan /audio-mode:2 /multimon /floatbar:sticky:off /gfx:RFX -themes -wallpaper \
/d:"${_domain}" \
/v:"${_host}" \
/u:"${_user}" \
/p:"${_password}"

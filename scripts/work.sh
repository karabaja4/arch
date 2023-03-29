#!/bin/sh
set -eu

_echo() {
    printf "$(tput setaf 1)%s$(tput sgr0)\n" "${1}"
}

_domain="$(jq -crM '.work.domain' "${HOME}/arch/secret.json")"
_host="$(jq -crM '.work.host' "${HOME}/arch/secret.json")"
_user="$(jq -crM '.work.user' "${HOME}/arch/secret.json")"
_password="$(jq -crM '.work.password' "${HOME}/arch/secret.json")"

_echo "Connecting to: ${_user} @ ${_domain}/${_host}"
exec xfreerdp /monitors:0 /cert-ignore /bpp:32 /network:lan /audio-mode:2 /multimon /floatbar:sticky:off /gfx:RFX -themes -wallpaper \
/d:"${_domain}" \
/v:"${_host}" \
/u:"${_user}" \
/p:"${_password}"

#!/bin/sh
set -u

_echo() {
    printf '[%s] %s\n' "$(date -Is)" "${1}"
}

_home="$(dirname "$(readlink -f "${0}")")"
_root="/var/www/certbot"

_work="${_root}/work"
_config="${_root}/config"
_logs="${_root}/logs"

mkdir -p "${_work}"
mkdir -p "${_config}"
mkdir -p "${_logs}"

_hook="${_home}/deploy-hook.sh"

_echo "Running certbot renew in ${_root}"

# run renew
certbot renew \
   --work-dir "${_work}" \
   --config-dir "${_config}" \
   --logs-dir "${_logs}" \
   --deploy-hook "${_hook}"

_echo "Exited certbot renew with ${?}"

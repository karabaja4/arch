#!/bin/sh
set -u

_root="${HOME}/certbot"

_work="${_root}/work"
_config="${_root}/config"
_logs="${_root}/logs"

mkdir -p "${_work}"
mkdir -p "${_config}"
mkdir -p "${_logs}"

_hook="${_root}/deploy-hook.sh"

certbot renew \
   --work-dir "${_work}" \
   --config-dir "${_config}" \
   --logs-dir "${_logs}" \
   --deploy-hook "${_hook}"

#!/bin/sh
set -u

_home="${HOME}/certbot"
_root="/var/www/certbot"

_work="${_root}/work"
_config="${_root}/config"
_logs="${_root}/logs"

mkdir -p "${_work}"
mkdir -p "${_config}"
mkdir -p "${_logs}"

_hook="${_home}/deploy-hook.sh"

certbot renew \
   --work-dir "${_work}" \
   --config-dir "${_config}" \
   --logs-dir "${_logs}" \
   --deploy-hook "${_hook}" >> "${_home}/renew.log" 2>&1

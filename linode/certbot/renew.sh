#!/bin/sh
set -u

_root="/home/igor/certbot"

_work="${_root}/work"
_config="${_root}/config"
_logs="${_root}/logs"
_hook="${_root}/deploy-hook.sh"

certbot renew \
   --work-dir "${_work}" \
   --config-dir "${_config}" \
   --logs-dir "${_logs}" \
   --deploy-hook "${_hook}"

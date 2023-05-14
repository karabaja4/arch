#!/bin/sh
set -u

_root="${HOME}/certbot"

_work="${_root}/work"
_config="${_root}/config"
_logs="${_root}/logs"

mkdir -p "${_work}"
mkdir -p "${_config}"
mkdir -p "${_logs}"

_creds="${_root}/creds.ini"

_email="burt.harbinson@outlook.com"
_domain1="aerium.hr"
_domain2="radiance.hr"

certbot certonly \
   --work-dir "${_work}" \
   --config-dir "${_config}" \
   --logs-dir "${_logs}" \
   --email "${_email}" \
   --agree-tos \
   --noninteractive \
   --dns-digitalocean-propagation-seconds 30 \
   --dns-digitalocean \
   --dns-digitalocean-credentials "${_creds}" \
   -d "${_domain1}" \
   -d "*.${_domain1}" \
   -d "${_domain2}" \
   -d "*.${_domain2}"
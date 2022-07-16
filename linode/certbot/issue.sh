#!/bin/sh
set -u

_root="/home/igor/certbot"

_work="${_root}/work"
_config="${_root}/config"
_logs="${_root}/logs"
_creds="${_root}/creds.ini"

_email="burt.harbinson@outlook.com"
_domain="aerium.hr"

mkdir -p "${_work}"
mkdir -p "${_config}"
mkdir -p "${_logs}"

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
   -d "${_domain}" \
   -d "*.${_domain}"

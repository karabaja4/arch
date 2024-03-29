#!/bin/sh
set -u

_home="$(dirname "$(readlink -f "${0}")")"
_root="/var/www/certbot"

_work="${_root}/work"
_config="${_root}/config"
_logs="${_root}/logs"

mkdir -p "${_work}"
mkdir -p "${_config}"
mkdir -p "${_logs}"

_creds="${_home}/creds.ini"

_certname="avacyn"
_email="burt.harbinson@outlook.com"
_domain1="radiance.hr"

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
   --cert-name "${_certname}" \
   --key-type rsa \
   --rsa-key-size 4096 \
   -d "${_domain1}" \
   -d "*.${_domain1}"

#!/bin/sh

#doas /usr/sbin/nginx -s reload
doas rc-service nginx restart

_home="$(dirname "$(readlink -f "${0}")")"
"${_home}/alert.sh"

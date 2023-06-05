#!/bin/sh

#doas /usr/sbin/nginx -s reload
doas rc-service nginx restart

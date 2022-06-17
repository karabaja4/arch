#!/bin/sh
set -u

_path="/dev/disk/by-uuid/23147c37-efb6-4837-83aa-87808c70b87a"

if [ -b "${_path}" ]
then
	df "${_path}" | tail -1 | awk '{print $2" "$4}'
else
	printf '%s %s\n' 0 0
fi

#!/bin/bash
set -euo pipefail

declare -r pid="$(cat /tmp/minirc/${1}.pid)"
sudo -u root strace -e write -p "${pid}" -s 10000 |& \
grep -oP --line-buffered '(?<=write\(1, ").*(?=\\n",)' | \
awk -v src="${1}" -v pid="${pid}" '{ print "["pid"]["src"]["strftime("%Y-%m-%dT%H:%M:%S")"] "$0; fflush(); }'


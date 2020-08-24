#!/bin/bash
set -euo pipefail

echo -n "mv" > /tmp/qtfm/action
printf "%s\n" "$@" > /tmp/qtfm/paths

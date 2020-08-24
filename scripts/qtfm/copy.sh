#!/bin/bash
set -euo pipefail

echo -n "cp" > /tmp/qtfm/action
printf "%s\n" "$@" > /tmp/qtfm/paths
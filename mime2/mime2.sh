#!/bin/bash
set -euo pipefail

declare -r dir="$(dirname "$(readlink -f "${0}")")"
declare -r result="$(node "${dir}/main.js" "${1}")"
echo "${result}" >> /home/igor/log.txt
declare -r cmd=(${result})
${cmd[@]}
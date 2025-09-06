#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"

_dir="$(dirname "$(readlink -f "${0}")")"

"${_dir}/mspclip.sh" &
wine64 "${_dir}/vista64/mspaint.exe"

kill -- -$$
printf '%s\n' 'End.'

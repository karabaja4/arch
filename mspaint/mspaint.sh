#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"

_dir="$(_script_dir)"

"${_dir}/mspclip.sh" &
wine64 "${_dir}/xp64/mspaint.exe"

kill -- -$$
printf '%s\n' 'End.'
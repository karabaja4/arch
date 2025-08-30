#!/bin/sh
. "/home/igor/arch/scripts/_lib.sh"

set -eu

_secret="/etc/secret/secret.json"

_domain="$(jq -crM '.work.domain' "${_secret}")"
_host="$(jq -crM '.work.host' "${_secret}")"
_user="$(jq -crM '.work.user' "${_secret}")"
_password="$(jq -crM '.work.password' "${_secret}")"

# alsa is sensitive to timings, underruns occur
export LD_LIBRARY_PATH="/usr/lib/apulse${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# /monitors:1
# /multimon

# /gfx:AVC444
# /gfx:RFX

# The client supports version 0xA0701 of the RDP graphics protocol, client mode: 2, AVC available: 1, Initial profile: 2. Server: XXX // AVC444
# The client supports version 0xA0701 of the RDP graphics protocol, client mode: 2, AVC available: 0, Initial profile: 2. Server: XXX // RFX
# The client supports RDP 7.1 or lower protocol. Server: XXX // no param
# The client supports version 0x80105 of the RDP graphics protocol, client mode: 0, AVC available: 0, Initial profile: 2. Server: XXX // Win 8.1

# WinXP
# The server security layer detected an error (0x80090304) in the protocol stream and the client (Client IP: 192.168.100.XX) has been disconnected.
# RDP_SEC: An error was encountered when transitioning from FStateActivated in response to FEventHandshakeFailed (error code 0x8007052E)

_color_echo 94 "Connecting to: ${_user} @ ${_domain}/${_host}"
exec xfreerdp3 /cert:ignore /bpp:32 /network:lan /audio-mode:0 /sound:sys:pulse /scale:100 /monitors:0 /floatbar:sticky:off /gfx:AVC444 /log-level:FATAL /timeout:30000 +f -themes -wallpaper -grab-keyboard \
/d:"${_domain}" \
/v:"${_host}" \
/u:"${_user}" \
/p:"${_password}"

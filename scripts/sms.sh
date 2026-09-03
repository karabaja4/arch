#!/bin/sh

PORT=/dev/ttyUSB2

exec 3<"$PORT"
exec 4>"$PORT"

_cmd()
{
    printf '%s\r' "$1" >&4
    timeout 1 cat <&3
}

_cmd 'AT'
_cmd 'AT+CMGF=1'
_cmd 'AT+CMGL="ALL"'
_cmd 'AT+CMGD=0'

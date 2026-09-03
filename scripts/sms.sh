#!/bin/sh

PORT=/dev/ttyUSB2

exec 3<"$PORT"
exec 4>"$PORT"

cmd()
{
    printf '%s\r' "$1" >&4
    timeout 1 cat <&3
}

cmd 'AT'
cmd 'AT+CMGF=1'
cmd 'AT+CMGL="ALL"'
cmd 'AT+CMGD=0'

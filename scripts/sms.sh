#!/bin/sh

_port='/dev/ttyUSB2'

stty -F "${_port}" raw -echo

exec 3<> "${_port}"

_cmd()
{
    printf '%s\r' "${1}" >&3
    timeout 0.2 cat <&3
}

_cmd 'AT'
_cmd 'AT+CMGF=1'
_cmd 'AT+CMGL="ALL"'
_cmd 'AT+CMGD=0'

# qmicli -d /dev/cdc-wdm0 --device-open-proxy --dms-swi-get-usb-composition
# qmicli -d /dev/cdc-wdm0 --device-open-proxy --dms-swi-set-usb-composition=8

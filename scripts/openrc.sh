#!/bin/sh
set -eu

_usage() {
    _bn="$(basename "${0}")"
    printf '%s\n' "Usage: ${_bn} [--help] <action> [daemon]" \
                  "" \
                  "Actions:" \
                  "   ${_bn} start [daemon]    starts daemon" \
                  "   ${_bn} stop [daemon]     stops daemon" \
                  "   ${_bn} restart [daemon]  restarts daemon" \
                  "   ${_bn} status [daemon]   daemon status" \
                  "   ${_bn} enable [daemon]   enable daemon" \
                  "   ${_bn} disable [daemon]  disable daemon" \
                  "   ${_bn} list              shows status of all daemons"
    exit 1
}

if [ "${#}" -eq 2 ]
then
    # start
    if [ "${1}" = "start" ] 
    then
        rc-service "${2}" start

    # stop
    elif [ "${1}" = "stop" ]
    then
        rc-service "${2}" stop

    # restart
    elif [ "${1}" = "restart" ]
    then
        rc-service "${2}" restart

    # status
    elif [ "${1}" = "status" ]
    then
        rc-service "${2}" status

    # enable
    elif [ "${1}" = "enable" ]
    then
        rc-update add "${2}" default

    # disable
    elif [ "${1}" = "disable" ]
    then
        rc-update del "${2}" default
    else
        _usage
    fi
elif [ "${#}" -eq 1 ]
then
    # list
    if [ "${1}" = "list" ]
    then
        rc-update -v show
    fi
else
    _usage
fi

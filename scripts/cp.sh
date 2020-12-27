#!/bin/bash
set -euo pipefail

cp "$@" &
declare -r pid=${!}

tput sc

_exit() {
    kill ${pid} > /dev/null 2>&1
    if [[ ${?} -eq 0 ]]
    then
        echo -ne "\nKilled ${pid}"
    fi
}

_print() {
    tput rc
    tput ed
    echo -n "${1}"
}

_progress() {
    /usr/bin/progress ${1:+"${1}"} -p ${pid} 2>/dev/null | sed 's/^\s*//'
}

trap "_exit" EXIT

declare line="$(_progress)"
if [[ "${line}" != "" ]]
then
    _print "${line}"
fi


while true
do
    line="$(_progress -w)"
    if [[ "${line}" == "" ]]
    then
        break
    fi
    _print "${line}"
done

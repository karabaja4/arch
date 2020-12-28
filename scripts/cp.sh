#!/bin/bash
set -euo pipefail

_dep() {
    if ! type "${1}" &> /dev/null
    then
        echo "${1} could not be found"
        exit
    fi
}

_dep "progress"
_dep "tput"

cp "$@" &
declare -r pid=${!}

_exit() {
    kill ${pid} > /dev/null 2>&1
    if [[ ${?} -eq 0 ]]
    then
        echo -ne "\nKilled ${pid}"
    fi
}

declare ln=0
_print() {
    if (( $ln > 0 ))
    then
        tput cuu ${ln}
        tput ed
    fi
    echo -e "${1}" | sed 's/^\s*//' | cut -c "-$(tput cols)"
    ln=2
}

_progress() {
    progress ${1:+"${1}"} -p ${pid} 2>/dev/null
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

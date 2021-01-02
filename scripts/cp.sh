#!/bin/bash
# shellcheck disable=SC2181

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
    if (( ${?} == 0 ))
    then
        echo -ne "\nKilled ${pid}"
    fi
}

declare ln=0
_print() {
    if [[ "${1}" == "" ]]
    then
        return 0
    fi
    if (( ln > 0 ))
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

_print "$(_progress)"

while true
do
    _print "$(_progress -w)"

    # die if cp finished
    kill -0 "${pid}" &> /dev/null
    if (( ${?} != 0 ))
    then
        break
    fi
done

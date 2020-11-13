#!/bin/bash
set -uo pipefail

declare -r path="/tmp/update_count"

if [ ! -f "${path}" ]
then
    echo "-" > "${path}"
    chmod 666 "${path}"
fi

declare -i rv=0
declare result=""

while true
do
    result="$(checkupdates | wc -l)"
    rv=${?}
    if [ ${rv} -eq 0 ] || [ ${rv} -eq 2 ]
    then
        echo "success (${rv})"
        echo "${result}" > "${path}"
        break
    fi
    echo "retrying (${rv})..."
    sleep 1
done

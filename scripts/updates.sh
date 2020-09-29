#!/bin/bash
set -uo pipefail

declare -i rv=0
declare result=""

while true
do
    result="$(checkupdates | wc -l)"
    rv=${?}
    if [[ ( ${rv} -eq 0 || ${rv} -eq 2 ) && ( ${result} != "" ) ]]
    then
        echo "success (${rv})"
        break
    fi
    echo "retrying (${rv})..."
    sleep 1
done

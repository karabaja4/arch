#!/bin/bash
set -uo pipefail

declare -i rv=0

while true
do
    checkupdates | wc -l > /tmp/update_count
    rv=$?
    if [ $rv -eq 0 ] || [ $rv -eq 2 ]
    then
        echo "success ($rv)"
        break
    fi
    echo "retrying ($rv)..."
    sleep 1
done

#!/bin/bash

DAEMONS=""
ENABLED=""
PIDDIR="/tmp/minirc"
declare -r CFGFILE="/etc/minirc.json"

_jq() {
    jq -crM ${1} <<< ${2}
}

while IFS='' read -r row
do
    declare name="$(_jq '.name' "${row}")"
    declare e="$(_jq '.enabled' "${row}")"
    DAEMONS="${DAEMONS} ${name}"
    if [ "${e}" = "true" ]
    then
        ENABLED="${ENABLED} ${name}"
    fi
done < <(jq -crM '.[]' < "$CFGFILE")

DAEMONS="${DAEMONS## }"
ENABLED="${ENABLED## }"

echo "DAEMONS: |${DAEMONS}|"
echo "ENABLED: |${ENABLED}|"

daemon_start() {
    while IFS='' read -r row
    do
        declare name="$(_jq '.name' "${row}")"
        if [ "${name}" = "${1}" ]
        then
            daemon_execute "${name}" "$(_jq '.user' "${row}")" "$(_jq '.command' "${row}")"
            return 0
        fi
    done < <(jq -crM '.[]' < "$CFGFILE")
    echo -e "Error: unknown service: ${1}"
}

daemon_execute() {
    echo "$1 $2 $3"
}

daemon_start dhcpcd
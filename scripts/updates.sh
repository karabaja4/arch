#!/bin/bash

declare -r countfile="/tmp/update_count"

[ ! -f "${countfile}" ] && echo "-" > "${countfile}"

while ! ping -q -c 1 -W 1 www.google.com &> /dev/null
do
    sleep 1
done

checkupdates | wc -l > "${countfile}"
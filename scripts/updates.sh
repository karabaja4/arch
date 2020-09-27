#!/bin/bash

while ! ping -q -c 1 -W 1 www.google.com &> /dev/null
do
    sleep 1
done

checkupdates | wc -l > "/tmp/update_count"
#!/bin/bash

while ! checkupdates | wc -l > /tmp/update_count
do
    sleep 1
done


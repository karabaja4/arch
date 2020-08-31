#!/bin/bash

declare ip=""
declare oldip=""
declare basedir="$(dirname "$(readlink -f "$0")")"
declare token="$(cat "$basedir/secret.json" | jq -r ".token")"
declare url="https://api.digitalocean.com/v2/domains/aerium.hr/records/53478297"

echo "Running in $basedir"

while true
do
    ip="$(curl -s -f "https://api.ipify.org")"
    if [ $? != 0 ]
    then
        echo "IP request failed."
    else
        if [ "$ip" != "$oldip" ]
        then
            curl -s -f -o /dev/null -X PUT -H "Content-Type: application/json" -H "Authorization: Bearer $token" -d "{\"data\":\"$ip\"}" "$url"
            if [ $? = 0 ]
            then
                echo "DigitalOcean request successful. New IP: $ip"
                echo "$(date): Updated DNS: $ip"
                oldip="$ip"
            else
                echo "DigitalOcean request failed."
            fi
        else
            echo "No changes ($ip)"
        fi
    fi 
    sleep 60
done

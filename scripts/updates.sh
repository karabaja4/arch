#!/bin/bash
set -euo pipefail

until checkupdates | wc -l > /tmp/update_count
do
    echo "retrying..."
    sleep 1
done


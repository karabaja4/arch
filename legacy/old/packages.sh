#!/bin/bash

for i in $(pacman -Qq)
do
    echo "-------------------------------------------------------------------------"
    printf "%-30s | %-30s\n" "${i}" "$(pacman -Rscp "${i}" | xargs)"
done
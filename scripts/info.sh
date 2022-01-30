#!/bin/sh
set -eu

clear

_mem_total_kb="$( grep "^MemTotal:" /proc/meminfo | awk '{ print $2 }' )"
_mem_available_kb="$( grep "^MemAvailable:" /proc/meminfo | awk '{ print $2 }' )"

_mem_used_gb="$( printf '%s %s' "${_mem_total_kb}" "${_mem_available_kb}" | awk '{ print ($1 - $2) / 1048576 }' )"
_mem_total_gb="$( printf '%s' "${_mem_total_kb}" | awk '{ print $1 / 1048576 }' )"

printf '\n'
printf '  Arch %s\n\n' "$(sed 's/ (.*//' /proc/version)"
printf '  * CPU:      %s\n' "$(grep 'model name' /proc/cpuinfo | head -n1 | sed 's/model name\t: //')"
printf '  * Memory:   %.2f GB / %.2f GB\n' "${_mem_used_gb}" "${_mem_total_gb}"
printf '  * Shell:    %s\n' "$(readlink /proc/$PPID/exe | sed 's/\/usr\/bin\///')"
printf '  * Uptime:   %s\n' "$(uptime -p | sed 's/up //')"
printf '  * Packages: %s (%s AUR)\n' "$(pacman -Qq | wc -l)" "$(pacman -Qm | wc -l)"
printf '\n'

printf '  '
_i=0
while [ ${_i} -le 15 ]
do
    if [ ${_i} = 8 ]
    then
        printf '\n  '
    fi
    printf '%s%s%s' "$(tput setaf "${_i}")" "████" "$(tput sgr0)"
    _i=$((_i+1))
done

printf '\n\n'

#/home/igor/arch/scripts/scrot.sh > /dev/null
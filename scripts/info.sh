#!/bin/sh
set -eu

clear

_mem() {
    awk '$3=="kB"{$2=$2/1024^2;$3="GB";} 1' /proc/meminfo | grep "${1}" | cut -d" " -f2
}

_mem_total="$(_mem "^MemTotal:")"
_mem_available="$(_mem "^MemAvailable:")"
_mem_used="$( printf '%s - %s\n' "${_mem_total}" "${_mem_available}" | bc )"

printf '\n'
printf '  Arch %s\n\n' "$(sed 's/) (.*/)/' /proc/version)"
printf '  * CPU:      %s\n' "$(grep 'model name' /proc/cpuinfo | head -n1 | sed 's/model name\t: //')"
printf '  * Memory:   %.2f GB / %.2f GB\n' "${_mem_used}" "${_mem_total}"
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

/home/igor/arch/scripts/scrot.sh > /dev/null
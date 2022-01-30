#!/bin/sh

clear

printf '\n'
printf '  Arch %s\n\n' "$(sed 's/) (.*/)/' /proc/version)"
printf '  * CPU:      %s\n' "$(grep 'model name' /proc/cpuinfo | head -n1 | sed 's/model name\t: //')"
printf '  * Memory:   %s\n' "4.8G / 11G"
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

printf '\n'
printf '\n'

/home/igor/arch/scripts/scrot.sh > /dev/null
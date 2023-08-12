#!/bin/sh
set -eu

clear

_mem_total_kb="$( grep "^MemTotal:" /proc/meminfo | awk '{ print $2 }' )"
_mem_available_kb="$( grep "^MemAvailable:" /proc/meminfo | awk '{ print $2 }' )"

_mem_used_gb="$( printf '%s %s' "${_mem_total_kb}" "${_mem_available_kb}" | awk '{ print ($1 - $2) / 1048576 }' )"
_mem_total_gb="$( printf '%s' "${_mem_total_kb}" | awk '{ print $1 / 1048576 }' )"

printf '\n'
printf '  %s @ %s\n\n' "$(cut -d '"' -f2 /etc/os-release | head -n1)" "$(cut -d' ' -f3 /proc/version)"
printf '  * CPU:      %s\n' "$(grep 'model name' /proc/cpuinfo | head -n1 | sed 's/model name\t: //')"
printf '  * Memory:   %.2f GB / %.2f GB\n' "${_mem_used_gb}" "${_mem_total_gb}"
printf '  * Shell:    %s\n' "$(readlink /proc/$PPID/exe | sed 's/\/usr\/bin\///')"
printf '  * Uptime:   %s\n' "$(uptime -p | cut -c 4-)"
printf '  * Packages: %s (%s AUR)\n' "$(pacman -Qq | wc -l)" "$(pacman -Qm | wc -l)"
printf '\n'

printf '  '

_print_color_row() {
    _i=0
    _base="${1}"
    while [ ${_i} -lt 8 ]
    do
        _code=$((_base+_i))
        printf '\033[%sm████\033[0m' "${_code}"
        _i=$((_i+1))
    done
}

_print_color_row 30
printf '\n  '
_print_color_row 90

printf '\n\n'

#/home/igor/arch/scripts/scrot.sh > /dev/null

#!/bin/sh
set -eu

clear

_uid="$(id -u)"

_get_lspci_gpu() {
    _gpu_name='unknown'
    if command -v lspci > /dev/null 2>&1
    then
        _gpu_line="$(lspci | grep 'VGA' | head -n1)"
        case "${_gpu_line}" in
            '')
                ;;
            *'['*']'*)
                _gpu_name="$(printf '%s\n' "${_gpu_line}" | awk -F'[][]' '{print $2}')"
                ;;
            *)
                _gpu_name="$(printf '%s\n' "${_gpu_line}" | awk -F':' '{ sub(/^ */, "", $NF); print $NF }')"
                ;;
        esac
    fi
    if [ "${_uid}" -eq 0 ]
    then
        # print gpu in color on welcome screen
        printf '\033[96m%s\033[0m\n' "${_gpu_name}"
    else
        printf '%s\n' "${_gpu_name}"
    fi
}

_get_nvidia_gpu() {
    if command -v nvidia-smi > /dev/null 2>&1
    then
        if _nvidia_out="$(nvidia-smi --query-gpu=gpu_name --format=csv,noheader 2>/dev/null)"
        then
            if [ "${_uid}" -eq 0 ]
            then
                # print gpu in color on welcome screen
                printf '\033[91m%s\033[0m\n' "${_nvidia_out}"
            else
                printf '%s\n' "${_nvidia_out}"
            fi
        else
            return 1
        fi
    else
        return 1
    fi
}

_get_distro() {
    cut -d '"' -f2 /etc/os-release | head -n1
}

_get_kernel() {
    cut -d' ' -f3 /proc/version
}

_get_cpu() {
    grep 'model name' /proc/cpuinfo | head -n1 | sed 's/model name\t: //'
}

_get_shell() {
    readlink "/proc/${PPID}/exe" | sed 's/\/usr\/bin\///'
}

_get_package_count() {
    pacman -Qq | wc -l
}

_get_aur_count() {
    pacman -Qm | wc -l
}

_get_uptime() {
    uptime -p | cut -c 4-
}

_mem_total_kb="$(grep "^MemTotal:" /proc/meminfo | awk '{ print $2 }')"
_mem_available_kb="$(grep "^MemAvailable:" /proc/meminfo | awk '{ print $2 }')"

_mem_used_gb="$(printf '%s %s' "${_mem_total_kb}" "${_mem_available_kb}" | awk '{ print ($1 - $2) / 1048576 }')"
_mem_total_gb="$(printf '%s' "${_mem_total_kb}" | awk '{ print $1 / 1048576 }')"

_system_model=''
if [ -r '/sys/class/dmi/id/product_version' ]
then
    _system_model="$(cat '/sys/class/dmi/id/product_version')"
fi

printf '\n'
if [ -n "${_system_model}" ]
then
    printf '  %s\n' "${_system_model}"
fi
printf '  %s @ %s\n\n' "$(_get_distro)" "$(_get_kernel)"
printf '  * CPU:      %s\n' "$(_get_cpu)"
printf '  * GPU:      %s\n' "$(_get_nvidia_gpu || _get_lspci_gpu)"
printf '  * Memory:   %.2f GB / %.2f GB\n' "${_mem_used_gb}" "${_mem_total_gb}"
printf '  * Shell:    %s\n' "$(_get_shell)"
printf '  * Uptime:   %s\n' "$(_get_uptime)"
printf '  * Packages: %s (%s AUR)\n' "$(_get_package_count)" "$(_get_aur_count)"
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

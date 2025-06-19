#!/bin/sh
set -eu
IFS='
'

_is_permission_value() {
    case "${1}" in
        [0-7][0-7][0-7][0-7])
        return 0
        ;;
    *)
        return 1
        ;;
    esac
}

_byte_to_bin() {
    printf '%s\n' "${1}" | cut -c "${2}" | printf '%s\n' "obase=2;$(cat -)" | bc | xargs printf '%03d\n'
}

_get_bit() {
    _bit="$(printf '%s' "${1}" | cut -c "${2}")"
    if [ "${_bit}" = "1" ]
    then
        printf 'X'
    else
        printf ' '
    fi
}

_output() {
    
    printf '\n'
    
    # $1 - filename
    if [ -n "${1}" ]
    then
        printf "  \033[37m#\033[0m Filename: %s\n" "${1}"
    fi
    
    # $2 - filetype
    if [ -n "${2}" ]
    then
        printf "  \033[37m#\033[0m Filetype: %s\n" "${2}"
    fi
    
    # $3 - permissions
    if [ -n "${3}" ]
    then
        printf "  \033[37m#\033[0m Permissions: \033[32m%s\033[0m\n" "${3}"
    fi
    
    # $4 - owner
    if [ -n "${4}" ]
    then
        printf "  \033[37m#\033[0m Owner: \033[36m%s\033[0m\n" "${4}"
    fi
    
    # table
    if [ -n "${5}" ] && [ -n "${6}" ] && [ -n "${7}" ] && [ -n "${8}" ] && [ -n "${9}" ]  && [ -n "${10}" ] && \
       [ -n "${11}" ] && [ -n "${12}" ] && [ -n "${13}" ] && [ -n "${14}" ] && [ -n "${15}" ] && [ -n "${16}" ]
    then
    printf "
          Read  Write Execute    Setuid Setgid Sticky
         ┌─────┬─────┬─────┐     ┌─────┬─────┬─────┐
  Owner  │  \033[32m%s\033[0m  │  \033[32m%s\033[0m  │  \033[32m%s\033[0m  │     │  \033[32m%s\033[0m  │  \033[32m%s\033[0m  │  \033[32m%s\033[0m  │
         ├─────┼─────┼─────┤     └─────┴─────┴─────┘
  Group  │  \033[32m%s\033[0m  │  \033[32m%s\033[0m  │  \033[32m%s\033[0m  │
         ├─────┼─────┼─────┤
  Public │  \033[32m%s\033[0m  │  \033[32m%s\033[0m  │  \033[32m%s\033[0m  │
         └─────┴─────┴─────┘

" "${5}" "${6}" "${7}" "${8}" "${9}" "${10}" "${11}" "${12}" "${13}" "${14}" "${15}" "${16}"
    fi
}

_print_permissions() {
    _byte1="$(_byte_to_bin "${3}" 1)"
    _byte2="$(_byte_to_bin "${3}" 2)"
    _byte3="$(_byte_to_bin "${3}" 3)"
    _byte4="$(_byte_to_bin "${3}" 4)"

    _setuid="$(_get_bit "${_byte1}" 1)"
    _setgid="$(_get_bit "${_byte1}" 2)"
    _sticky="$(_get_bit "${_byte1}" 3)"

    _owner_read="$(_get_bit "${_byte2}" 1)"
    _owner_write="$(_get_bit "${_byte2}" 2)"
    _owner_exec="$(_get_bit "${_byte2}" 3)"

    _group_read="$(_get_bit "${_byte3}" 1)"
    _group_write="$(_get_bit "${_byte3}" 2)"
    _group_exec="$(_get_bit "${_byte3}" 3)"

    _public_read="$(_get_bit "${_byte4}" 1)"
    _public_write="$(_get_bit "${_byte4}" 2)"
    _public_exec="$(_get_bit "${_byte4}" 3)"

    _output "${1}" "${2}" "${3}" "${4}" \
            "${_owner_read}" "${_owner_write}" "${_owner_exec}" "${_setuid}" "${_setgid}" "${_sticky}" \
            "${_group_read}" "${_group_write}" "${_group_exec}" \
            "${_public_read}" "${_public_write}" "${_public_exec}"
}

_usage() {
    printf "permof 1.1 - visualize permissions of a file or a directory.
usage: %s [-h] [-q MODE] [FILE]...
  --help, -h        Show this help list.
  --query, -q MODE  Show visualization for the provided octal permission (e.g. 0755)
" "$(basename "${0}")"
    exit 1
}

_error() {
    printf "\033[91mERROR: %s\033[0m\n" "${1}"
}

if [ "${#}" -eq 0 ]
then
    _usage
elif [ "${#}" -eq 1 ] && { [ "${1}" = "-h" ] || [ "${1}" = "--help" ]; }
then
    _usage
elif [ "${#}" -eq 2 ] && { [ "${1}" = "-q" ] || [ "${1}" = "--query" ]; }
then
    if _is_permission_value "${2}"
    then
        _print_permissions "" "" "${2}" ""
    else
        _error "${2} is not a valid permission value, must be an octal 4 digit value."
        exit 1
    fi
else
    for _item in "${@}"
    do
        if [ -f "${_item}" ] || [ -d "${_item}" ]
        then
            # filename
            # filetype
            # permissions
            # owner
            _print_permissions \
                "$(stat -c '%n' "${_item}")" \
                "$(stat -c '%F' "${_item}")" \
                "$(stat -c '%04a' "${_item}")" \
                "$(stat -c '%U:%G' "${_item}")"
        else
            _error "${_item} is not a file or directory"
        fi
    done
fi

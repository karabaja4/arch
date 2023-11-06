#!/bin/sh
set -eu
IFS='
'

_echo() {
    printf '%s\n' "${@}"
}

_usage() {
    _echo \
    "permof 1.0 - visualize permissions of a file or a directory." \
    "usage: $(basename "${0}") [FILE]..."
    exit 1
}

[ "${#}" -lt 1 ] && _usage


_byte_to_bin() {
    _echo "${1}" | cut -c "${2}" | _echo "obase=2;$(cat -)" | bc | xargs printf '%03d\n'
}

_get_bit() {
    _bit="$(_echo "${1}" | cut -c "${2}")"
    if [ "${_bit}" = "1" ]
    then
        _echo "X"
    else
        _echo " "
    fi
}

_output() {
printf "
  \033[37m#\033[0m Filename: %s
  \033[37m#\033[0m Filetype: %s
  \033[37m#\033[0m Permissions: \033[32m%s\033[0m
  \033[37m#\033[0m Owner: \033[36m%s\033[0m

          Read  Write Execute    Setuid Setgid Sticky
         ┌─────┬─────┬─────┐     ┌─────┬─────┬─────┐
  Owner  │  \033[32m%s\033[0m  │  \033[32m%s\033[0m  │  \033[32m%s\033[0m  │     │  \033[32m%s\033[0m  │  \033[32m%s\033[0m  │  \033[32m%s\033[0m  │
         ├─────┼─────┼─────┤     └─────┴─────┴─────┘
  Group  │  \033[32m%s\033[0m  │  \033[32m%s\033[0m  │  \033[32m%s\033[0m  │
         ├─────┼─────┼─────┤
  Public │  \033[32m%s\033[0m  │  \033[32m%s\033[0m  │  \033[32m%s\033[0m  │
         └─────┴─────┴─────┘

" \
"${1}" "${2}" "${3}" "${4}" \
"${5}" "${6}" "${7}" "${8}" "${9}" "${10}" \
"${11}" "${12}" "${13}" \
"${14}" "${15}" "${16}"
}

for _item in "${@}"
do
    _filename="$(stat -c '%n' "${_item}")"
    _filetype="$(stat -c '%F' "${_item}")"
    _owner="$(stat -c '%U:%G' "${_item}")"
    _permissions="$(stat -c '%04a' "${_item}")"
    
    _byte1="$(_byte_to_bin "${_permissions}" 1)"
    _byte2="$(_byte_to_bin "${_permissions}" 2)"
    _byte3="$(_byte_to_bin "${_permissions}" 3)"
    _byte4="$(_byte_to_bin "${_permissions}" 4)"

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

    _output "${_filename}" "${_filetype}" "${_permissions}" "${_owner}" \
            "${_owner_read}" "${_owner_write}" "${_owner_exec}" "${_setuid}" "${_setgid}" "${_sticky}" \
            "${_group_read}" "${_group_write}" "${_group_exec}" \
            "${_public_read}" "${_public_write}" "${_public_exec}"
done

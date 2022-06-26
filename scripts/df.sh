#!/bin/sh
set -eu

_echo() {
    printf '%s\n' "${1}"
}

_dir="${HOME}/.local/share/diskusage"
mkdir -p "${_dir}"
_out="${_dir}/df"

_exit() {
    exit "${1}"
}

if pgrep -x "df"
then
    _echo "df is running"
    exit 1
else
    _df="$(df)"
    _dfec=${?}
    if [ "${_dfec}" -eq 0 ]
    then
        _echo "${_df}" > "${_out}"
        _echo "df successfully executed"
        _exit 0
    else
        _echo "df failed"
        _exit 1
    fi
fi

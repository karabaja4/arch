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

if pgrep -x "df" > /dev/null
then
    _echo "df is running"
    exit 1
else
    _df="$(df)"
    _dfec=${?}
    if [ "${_dfec}" -eq 0 ]
    then
        if [ ! -f "${_out}" ]
        then
            _echo "${_df}" | sed '1d' > "${_out}"
            _echo "df file initialized"
        fi
        # merge latest df with old df
        _echo "${_df}" | sed '1d' | cat - "${_out}" | sort -V -u -k1,1 > "${_out}.tmp" && mv "${_out}.tmp" "${_out}"
        _echo "df successfully executed"
        _exit 0
    else
        _echo "df failed"
        _exit 1
    fi
fi

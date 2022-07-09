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
        _stripped="$(_echo "${_df}" | awk 'NR>1{print $6, $2, $3, $4}')"
        if [ ! -f "${_out}" ]
        then
            _echo "${_stripped}" > "${_out}"
            _echo "df file initialized"
        fi
        # merge latest df with old df
        _echo "${_stripped}" | cat - "${_out}" | sort -k1,1 -u > "${_out}.tmp" && mv "${_out}.tmp" "${_out}"
        _echo "df successfully executed"
        _exit 0
    else
        _echo "df failed"
        _exit 1
    fi
fi

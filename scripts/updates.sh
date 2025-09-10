#!/bin/sh
. "$(dirname "$(readlink -f "${0}")")/_lib.sh"

# multiple checkupdates calls cannot run in parallel
# that is why a new CHECKUPDATES_DB is created only for this script

# auracle returns 0 when there are upgradable packages and stdout is non-empty
# auracle returns 1 when check is successful and no packages are upgradable, with empty stdout + stderr
# auracle also returns 1 when check failed, with non-empty stdout+stderr
# so if return code is non-zero, stdour+stderr should be empty, otherwise it should be handled as a failure

_root="${HOME}/.local/share/updatecount"
mkdir -p "${_root}"

export CHECKUPDATES_DB="${_root}"

_aur() {

    _aur_out="$(/usr/bin/auracle outdated 2>&1)"
    _aur_rv="${?}"
    _aur_wc=""

    if [ "${_aur_rv}" -eq 0 ] && [ -n "${_aur_out}" ]
    then
        _aur_wc="$(_nelc "${_aur_out}")"
    elif [ "${_aur_rv}" -eq 1 ] && [ -z "${_aur_out}" ]
    then
        _aur_wc="0"
    else
        _fatal "auracle failed with [${_aur_rv}]:" "[${_aur_out}]"
    fi

    if [ -n "${_aur_wc}" ]
    then
        _echo "Found ${_aur_wc} AUR updates."
        _echo "${_aur_wc}" > "${_root}/aur"
    fi
}

_cu() {

    _cu_out="$(/usr/bin/checkupdates 2>&1)"
    _cu_rv="${?}"
    _cu_wc=""

    if [ "${_cu_rv}" -eq 0 ] && [ -n "${_cu_out}" ]
    then
        _cu_wc="$(_nelc "${_cu_out}")"
    elif [ "${_cu_rv}" -eq 2 ] && [ -z "${_cu_out}" ]
    then
        _cu_wc="0"
    else
        _fatal "checkupdates failed with [${_cu_rv}]:" "[${_cu_out}]"
    fi

    if [ -n "${_cu_wc}" ]
    then
        _echo "Found ${_cu_wc} pacman updates."
        _echo "${_cu_wc}" > "${_root}/pacman"
    fi
}

_aur
_cu

#!/bin/sh
set -u

_fn="$(basename "${0}")"

_log() {
    printf '[%s][%s] %s\n' "${_fn}" "$(date -Is)" "${1}"
}

if [ "$(id -u)" -ne 0 ]
then
    _log "Root privileges are required to run this script."
    exit 1
fi

_root_dir="/root/.local/share/fstrim"
_last_run_file="${_root_dir}/lastruntime"
_log_file="${_root_dir}/log"

# ensure directories exists
mkdir -p "${_root_dir}"

# get current time (seconds since epoch)
_now="$(date +%s)"

# Read last run timestamp if it exists
if [ -f "${_last_run_file}" ]
then
    _last_run="$(cat "${_last_run_file}")"
else
    _last_run="0"
fi

# check if enough time has passed
# one week
_interval="$((7 * 24 * 60 * 60))"
_time_passed="$((_now - _last_run))"

if [ "${_time_passed}" -ge "${_interval}" ]
then
    {
        _log "Starting fstrim"
        /usr/bin/fstrim --listed-in /etc/fstab:/proc/self/mountinfo --verbose --quiet-unsupported
        _exit_code="${?}"
        _log "fstrim exited with ${_exit_code}"
    } >> "${_log_file}" 2>&1
    
    if [ "${_exit_code}" -eq 0 ]
    then
        printf '%s\n' "${_now}" > "${_last_run_file}"
    fi
else
    _log "Time passed: ${_time_passed}/${_interval}, skipping." >> "${_log_file}"
fi

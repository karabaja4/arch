#!/bin/sh
. "$(dirname "$(readlink -f "${0}")")/_lib.sh"

_must_be_root

_root_dir="/root/.local/share/fstrim"
_last_run_file="${_root_dir}/lastruntime"

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
    _log "Time passed: ${_time_passed} >= ${_interval}, starting fstrim."
    /usr/bin/fstrim --listed-in /etc/fstab:/proc/self/mountinfo --verbose --quiet-unsupported | _log
    _exit_code="${?}"
    _log "fstrim exited with ${_exit_code}"
    
    if [ "${_exit_code}" -eq 0 ]
    then
        printf '%s\n' "${_now}" > "${_last_run_file}"
    fi
else
    _log "Time passed: ${_time_passed} < ${_interval}, skipping."
fi

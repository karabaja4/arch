#!/bin/sh
set -eu

_echo() {
    printf '%s\n' "${1}"
}

_shot() {
    _idx=1
    _dir="/tmp/screenshots"
    mkdir -p "${_dir}"
    _ts="$(date +%s%N)"
    for _res in $(xrandr | grep -o '[0-9]*x[0-9]*[+-][0-9]*[+-][0-9]*' | sort -n -t '+' -k2)
    do
        _fn="${_dir}/${_ts}_${_idx}.png"
        _echo "Screenshoting: ${_res} (${_idx}) -> ${_fn}"
        maim -u -g "${_res}" > "${_fn}"
        _idx=$(( _idx + 1 ))
    done

    _vfn1="${_dir}/v_${_ts}.png"
    _hfn1="${_dir}/h_${_ts}.png"
    _vfn2="${_dir}/${_ts}_vertical.png"
    _hfn2="${_dir}/${_ts}_horizontal.png"

   _echo "Creating vertical tile: ${_vfn2}" 
    convert -append "${_dir}/${_ts}_*.png" "${_vfn1}"

    _echo "Creating horizontal tile: ${_hfn2}" 
    convert +append "${_dir}/${_ts}_*.png" "${_hfn1}" 

    mv "${_vfn1}" "${_vfn2}"
    mv "${_hfn1}" "${_hfn2}"
}

mkdir -p /tmp/screenshots/
_shot
_echo "done."
#!/bin/sh

_sockdir="/tmp/.X11-unix"
if [ ! -d "${_sockdir}" ]
then
    printf '%s\n' "${_sockdir} does not exist, exiting."
    exit 1
fi

sudo modprobe -v nvidia
sudo modprobe -v nvidia_uvm
sudo modprobe -v nvidia_modeset
sudo modprobe -v nvidia_drm modeset=1

export LD_LIBRARY_PATH=/usr/lib64/nvidia/:/usr/lib32/nvidia:/usr/lib:${LD_LIBRARY_PATH}

_root_dir="$(dirname "$(readlink -f "${0}")")"
_config_name="nvidia-xorg"

sudo ln -sfvT "${_root_dir}/${_config_name}.conf" "/etc/X11/${_config_name}.conf"
sudo ln -sfvT "${_root_dir}/${_config_name}.conf.d" "/etc/X11/${_config_name}.conf.d"

_get_screen() {
    _index=0
    while [ -e "${_sockdir}/X${_index}" ]
    do
        _index=$(( _index + 1 ))
    done
    printf '%s\n' "${_index}"
}

exec xinit "${_root_dir}/xinitrc" -- ":$(_get_screen)" "vt$(fgconsole)" -nolisten tcp -br -config "${_config_name}.conf" -configdir "${_config_name}.conf.d"

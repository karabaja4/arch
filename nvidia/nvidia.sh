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

_rootdir="$(dirname "$(readlink -f "${0}")")"
_conf="nvidia-xorg.conf"

sudo ln -sfvT "${_rootdir}/${_conf}" "/etc/X11/${_conf}"
sudo ln -sfvT "${_rootdir}/${_conf}.d" "/etc/X11/${_conf}.d"

_get_screen() (
    _index=0
    while [ -e "${_sockdir}/X${_index}" ]
    do
        _index=$(( _index + 1 ))
    done
    printf '%s\n' "${_index}"
)

exec xinit "${_rootdir}/xinitrc" -- ":$(_get_screen)" "vt$(fgconsole)" -nolisten tcp -br -config "${_conf}" -configdir "${_conf}.d"

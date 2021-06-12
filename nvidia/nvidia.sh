#!/bin/sh

sudo modprobe nvidia
sudo modprobe nvidia_uvm
sudo modprobe nvidia_modeset
sudo modprobe nvidia_drm modeset=1

export LD_LIBRARY_PATH=/usr/lib64/nvidia/:/usr/lib32/nvidia:/usr/lib:${LD_LIBRARY_PATH}

_rootdir="$(dirname "$(readlink -f "${0}")")"
sudo ln -sfv "${_rootdir}/nvidia-xorg.conf" "/etc/X11/nvidia-xorg.conf"
sudo ln -sfv "${_rootdir}/nvidia-xorg.conf.d" "/etc/X11/nvidia-xorg.conf.d"

exec xinit "${_rootdir}/xinitrc" -- :0 vt"$(fgconsole)" -nolisten tcp -br -config nvidia-xorg.conf -configdir nvidia-xorg.conf.d

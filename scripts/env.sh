#!/bin/sh

# exports
export QT_QPA_PLATFORMTHEME='qt6ct'
export QT_ENABLE_HIGHDPI_SCALING=1
export NO_AT_BRIDGE=1
export EDITOR='nano'
export DOTNET_CLI_TELEMETRY_OPTOUT=true
export DOTNET_GENERATE_ASPNET_CERTIFICATE=false
export LESSHISTFILE=/dev/null
export BROWSER='chromium'
export HISTFILESIZE=2000
export GIT_PS1_SHOWCONFLICTSTATE='no'

# default scaling
# QT (1.75*96)
# https://doc.qt.io/qt-6/highdpi.html
export QT_FONT_DPI=168
# GTK
export GDK_SCALE=2

# vnc does not export $SHELL
export SHELL='/bin/bash'

# xdg
_xdg_runtime_dir="/run/user/$(id -u)"
export XDG_RUNTIME_DIR="${_xdg_runtime_dir}"

# path
export PATH="${PATH}:${HOME}/.dotnet/tools"
export JSII_SILENCE_WARNING_UNTESTED_NODE_VERSION=1

# $HOME/.config/glib-2.0/settings/keyfile
# filepicker settings
export GSETTINGS_BACKEND='keyfile'
export ALSOFT_DRIVERS='alsa'

# firefox
export MOZ_DISABLE_RDD_SANDBOX=1
export MOZ_CRASHREPORTER_DISABLE=1

# VDPAU
if nvidia-smi --query-gpu=gpu_name --format=csv,noheader > /dev/null 2>&1
then
    export LIBVA_DRIVER_NAME='nvidia'
else
    export LIBVA_DRIVER_NAME='iHD'
fi

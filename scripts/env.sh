#!/bin/sh

# exports
export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export NO_AT_BRIDGE=1
export EDITOR=nano
export DOTNET_CLI_TELEMETRY_OPTOUT=true
export LESSHISTFILE=/dev/null

# xdg
export XDG_DOWNLOAD_DIR="${HOME}/downloads"
export XDG_DESKTOP_DIR="/tmp/xdg-igor/desktop"
export XDG_RUNTIME_DIR="/tmp/xdg-igor/runtime"

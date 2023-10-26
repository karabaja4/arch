#!/bin/sh

# exports
export QT_QPA_PLATFORMTHEME='qt5ct'
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export NO_AT_BRIDGE=1
export EDITOR='nano'
export DOTNET_CLI_TELEMETRY_OPTOUT=true
export DOTNET_GENERATE_ASPNET_CERTIFICATE=false
export LESSHISTFILE=/dev/null
export BROWSER='firefox-socket'
export HISTFILESIZE=2000
export GIT_PS1_SHOWCONFLICTSTATE="no"

# vnc does not export $SHELL
export SHELL='/bin/bash'

# xdg
export XDG_RUNTIME_DIR='/tmp/xdg-igor/runtime'

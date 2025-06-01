#!/bin/sh

# exports
export QT_QPA_PLATFORMTHEME='qt6ct'
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export NO_AT_BRIDGE=1
export EDITOR='nano'
export DOTNET_CLI_TELEMETRY_OPTOUT=true
export DOTNET_GENERATE_ASPNET_CERTIFICATE=false
export LESSHISTFILE=/dev/null
export BROWSER='chromium'
export HISTFILESIZE=2000
export GIT_PS1_SHOWCONFLICTSTATE="no"

# default scaling
# QT
#export QT_FONT_DPI=150
# GTK
#export GDK_SCALE=1

# vnc does not export $SHELL
export SHELL='/bin/bash'

# xdg
export XDG_RUNTIME_DIR='/tmp/xdg-igor/runtime'

# path
export PATH="${PATH}:${HOME}/.dotnet/tools"
export JSII_SILENCE_WARNING_UNTESTED_NODE_VERSION=1

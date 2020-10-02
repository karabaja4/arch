#!/bin/bash

if [ "${1}" != "speakers" ] && [ "${1}" != "headset" ]
then
    echo "wrong parameter"
    exit 1
fi

declare -r basedir="$(dirname "$(readlink -f "${0}")")"
ln -sf "${basedir}/asoundrc.${1}" "${HOME}/.asoundrc"
alsactl -f "${basedir}/asound.state.${1}" restore
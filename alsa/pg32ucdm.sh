#!/bin/sh

rm /home/igor/.asoundrc
input_line="$(aplay -l | grep PG32UCDM)"

card=$(printf "%s\n" "$input_line" | sed -n 's/.*card \([0-9][0-9]*\):.*/\1/p')
device=$(printf "%s\n" "$input_line" | sed -n 's/.*device \([0-9][0-9]*\):.*/\1/p')

printf "defaults.ctl.card %s\ndefaults.pcm.card %s\ndefaults.pcm.device %s\n" "$card" "$card" "$device" | tee /home/igor/.asoundrc

amixer set IEC958,0 unmute

aplay /home/igor/arch/alsa/notify48k.wav

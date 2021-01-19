#!/bin/bash

if grep -q "RUNNING" /proc/asound/card*/pcm*/sub*/status
then
    xset -display :0 s off -dpms
else
    xset -display :0 s on +dpms
fi
#!/bin/bash

if grep -q "RUNNING" /proc/asound/card*/pcm*/sub*/status
then
    xset s off -dpms
else
    xset s on +dpms
fi
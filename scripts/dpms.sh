#!/bin/bash

if grep -q "RUNNING" /proc/asound/card*/pcm*/sub*/status
then
    xset -display :0.0 dpms 0 0 0
else
    xset -display :0.0 dpms 300 300 300
fi
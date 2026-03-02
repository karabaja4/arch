#!/bin/sh

exec mpv \
--vo=gpu \
--hwdec=vaapi \
--script-opts=osc-fadeduration=0,osc-scalefullscreen=0.5 \
"${@}"

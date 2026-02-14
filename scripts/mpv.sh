#!/bin/sh

exec mpv \
--vo=gpu \
--hwdec=nvdec \
--script-opts=osc-fadeduration=0,osc-scalefullscreen=0.5 \
"${@}"

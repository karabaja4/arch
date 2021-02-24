#!/bin/bash

pkill -f tint2rc-top
sleep 1
( tint2 -c "${HOME}/arch/tint2/tint2rc-top" & )

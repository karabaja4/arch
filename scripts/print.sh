#!/bin/bash

mutt -s "hpeprint" -a "$1" < /dev/null -- karabaja4@hpeprint.com

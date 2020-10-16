#!/bin/bash
set -uo pipefail

modprobe -a vmw_vmci vmmon vmnet

#/usr/bin/vmware-networks --postinstall vmware-player,0,1
#/usr/bin/vmware-authdlauncher

/usr/bin/vmware-networks --start
/usr/lib/vmware/bin/vmware-usbarbitrator -f

trap '/usr/bin/vmware-networks --stop' INT TERM EXIT
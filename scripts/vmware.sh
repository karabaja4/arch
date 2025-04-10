#!/bin/sh

modprobe -a vmw_vmci vmmon vmnet

#/usr/bin/vmware-networks --postinstall vmware-player,0,1
/usr/bin/vmware-networks --start
/usr/lib/vmware/bin/vmware-usbarbitrator -f
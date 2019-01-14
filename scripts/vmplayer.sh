#!/bin/bash

sudo sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/enabled'
sudo sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/defrag'
sudo sh -c 'echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/defrag'

sleep 1

sudo systemctl start vmware-networks.service
sudo systemctl start vmware-usbarbitrator.service
sudo systemctl start vmware-hostd.service

sleep 1

vmware

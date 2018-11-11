#!/bin/bash

sudo systemctl start vmware-networks.service
sudo systemctl start vmware-usbarbitrator.service
sudo systemctl start vmware-hostd.service
vmplayer

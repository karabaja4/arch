#!/bin/bash

sudo mount -t cifs -o username="root",password="$1",file_mode=0777,dir_mode=0777 //20.0.0.1/shared /home/igor/shared/

sudo mount -t cifs //192.168.0.10/storage _nas/ -o username=root,password=password,vers=1.0,uid=$(id -u),gid=$(id -g)
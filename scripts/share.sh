#!/bin/bash

sudo mount -t cifs -o username="root",password="$1",file_mode=0777,dir_mode=0777 //20.0.0.1/shared /home/igor/shared/

#!/bin/bash
set -euo pipefail

declare -r vncdir="/home/igor/.vnc"
declare -r piddir="/tmp/minirc"

echo "clearing old sessions..."
rm -f ${vncdir}/*.pid
rm -f ${vncdir}/*.log

echo "starting server..."
/usr/bin/vncserver :1 &

echo "copying PID..."
sleep 2
sudo -u root sh -c "pgrep Xvnc > ${piddir}/vnc.pid"
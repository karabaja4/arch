#!/bin/bash

declare -r VNCDIR="/home/igor/.vnc"
declare -r PIDDIR="/tmp/minirc"

echo "clearing old PIDs..."
rm -f ${VNCDIR}/*.pid
rm -f ${VNCDIR}/*.log

echo "starting server..."
/usr/bin/vncserver :1

echo "copying PID..."
cp ${VNCDIR}/*.pid ${PIDDIR}/vnc.pid &> /dev/null

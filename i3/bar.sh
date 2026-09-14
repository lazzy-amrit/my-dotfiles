#!/bin/bash

while true; do
    RAM=$(free -h | awk '/Mem/ {print $3 "/" $2}')
    DISK=$(df -h / | awk 'NR==2 {print $3 "/" $2}')

    TEMP=$(sensors | awk '/Package id 0:/ {print $4; exit}' | tr -d '+')
    [ -z "$TEMP" ] && TEMP="N/A"

    TIME=$(date '+%I:%M %p')

    echo " $RAM | $DISK | CPU $TEMP | $TIME "
    sleep 10
done
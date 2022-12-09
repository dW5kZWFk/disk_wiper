#!/bin/bash

echo "usb device connected $1" >> /tmp/snip.txt

#monitor dd / get PID
#dd if=/dev/urandom of=/dev/sda conv=sparse bs=262144 & bgid=$!; while true; do sleep 1; kill -USR1 $bgid || break; sleep 4; donec

#progress bar: (percentage estimated with sizeprobe value)
#dcfldd if=/dev/zero of=/dev/sda status=on sizeprobe=of

#sudo ./arcconf getconfig 1 ld | grep -A 18 '<identifier>' | grep 'Slot:'

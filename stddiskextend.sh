#!/bin/bash

largest_fs=$(df -h | grep "^/dev/sda" | awk -F"/dev/sda| " '{print $2}' | sort -k 2 -rh | head -n 1)

echo 1 > /sys/class/block/sda/device/rescan
sleep 3
echo 1 > /sys/class/block/sda/device/rescan

growpart /dev/sda $largest_fs
resize2fs /dev/sda$largest_fs

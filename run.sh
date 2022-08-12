#!/bin/bash

echo ""
echo "Run Linux Desktop Base"
echo "----------------------"

docker run -it \
 --shm-size 512m \
 --cap-add=SYS_PTRACE \
 --tmpfs /tmp \
 --tmpfs /run \
 --tmpfs /run/lock \
 --volumes-from Apps-Shared \
 --volumes-from Data-Shared \
 -p 8005:11 -p 22005:22 -p 59005:5901 \
 --name box-5 \
 --hostname box-5 \
 cameek/linux-desktop-base:0.2
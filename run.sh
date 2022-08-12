#!/bin/bash

echo ""
echo "Run Linux Desktop Base"
echo "----------------------"

docker run -it \
 --shm-size 512m \
 --volumes-from shared-apps \
 --volumes-from shared-data \
 -p 8006:11 -p 22006:22 -p 59006:5901 \
 --name box-6 \
 --hostname box-6 \
 cameek/linux-desktop-base:0.3
#!/bin/bash

echo "Run Linux Desktop Extended"
echo "--------------------------"

docker run -it \
 --shm-size 512m \
 --volumes-from shared-apps \
 --volumes-from shared-data \
 -p 8008:11 -p 22008:22 -p 59008:5901 \
 --name box-8 \
 --hostname box-8 \
 cameek/linux-desktop-extend:0.4
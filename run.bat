@echo Run Linux Desktop Extended
@echo ----------------------------

docker run -it ^
 --shm-size 512m ^
 --tmpfs /tmp ^
 --tmpfs /run ^
 --tmpfs /run/lock ^
 -p 81:11 -p 22001:22 -p 59001:5901 ^
 --volume /apps/shared ^
 --volume /data/box-1 ^
 --name box-1 ^
 --hostname box-1 ^
 cameek/linux-desktop-extend:0.1
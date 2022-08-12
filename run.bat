@echo Run Linux Desktop Base
@echo ----------------------

docker run -it ^
 --shm-size 512m ^
 --tmpfs /tmp ^
 --tmpfs /run ^
 --tmpfs /run/lock ^
 -p 8004:11 -p 22004:22 -p 59004:5901 ^
 --volume /apps/shared ^
 --volume /data/box-4 ^
 --name box-4 ^
 --hostname box-4 ^
 cameek/linux-desktop-base:0.2
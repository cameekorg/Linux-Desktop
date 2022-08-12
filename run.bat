@echo Run Linux Desktop Base
@echo ----------------------

docker run -it ^
 --shm-size 512m ^
 -p 8004:11 -p 22004:22 -p 59004:5901 ^
 --volumes-from shared-apps ^
 --volumes-from shared-data ^
 --name box-4 ^
 --hostname box-4 ^
 cameek/linux-desktop-base:0.3
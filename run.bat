@echo Run Linux Desktop Extended
@echo ----------------------------

docker run -it ^
 --shm-size 512m ^
 --cap-add=SYS_PTRACE ^
 --tmpfs /tmp ^
 --tmpfs /run ^
 --tmpfs /run/lock ^
 --volume /sys/fs/cgroup:/sys/fs/cgroup:ro ^
 --volume /lib/modules:/lib/modules:ro ^
 --volume /etc/timezone:/etc/timezone:ro ^
 --volume /etc/localtime:/etc/localtime:ro ^
 -p 81:11 -p 22001:22 -p 59001:5901 ^
 --name box-1 ^
 --hostname box-1 ^
 cameek/linux-desktop-extend:0.1
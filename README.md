# Linux-Desktop
Another Linux Desktop

```mermaid
flowchart LR
  OS[Oracle Linux 8.6]
  SVC[SystemD]
  UI[XFCE4]
```

### BCI-3 : Build and Tag Image

```sh
docker build --tag linux-desktop:8 .
```



### BCI-4 : Run Docker Image

```sh
docker run -it \
 --shm-size 512m \
 --cap-add=SYS_PTRACE \
 --tmpfs /tmp \
 --tmpfs /run \
 --tmpfs /run/lock \
 --volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
 --volume /lib/modules:/lib/modules:ro \
 --volume /etc/timezone:/etc/timezone:ro \
 --volume /etc/localtime:/etc/localtime:ro \
 -p 22007:22 -p 59007:5901 -p 40007:4000 \
 --name linux-desktop-8 \
 --hostname linux-desktop-8 \
linux-desktop:8
```



## TimeZone Issues Explained



https://hoa.ro/blog/2020-12-08-draft-docker-time-timezone/



## Install NoVNC 1.3.0

```sh
pip3 install numpy
cd /tmp
git clone https://github.com/novnc/noVNC.git
cd /tmp/noVNC
git checkout tags/v1.3.0
cd /tmp/noVNC/utils
```


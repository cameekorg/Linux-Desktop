# Linux Desktop Docker

Extension of Base Linux Desktop Docker image.

Consists of following components:

```mermaid
flowchart LR
  OS[Oracle Linux 8.6]-..-
  SVC[Supervisor]-..-
  UI[XFCE4]-..-
  VNC[TigerVNC]-..-
  HTTP[NoVNC]
```

## 1. Build and Tag Image

On Linux:
```sh
./build.sh
```
On Windows:
```bat
build.bat
```
Or via Docker CLI:
```sh
docker build --tag cameek/linux-desktop-extend:0.3 .
```

## 2. Create Persistent Shared Volumes

The volumes are used to:
- keep your home data safe (/shared/data)
- to optimize disk space by re-using applications (/shared/apps)

On Linux:
```sh
./volumes-create.sh
```
On Windows:
```bat
volumes-create.bat
```
Or via Docker CLI:
```sh
docker run -v shared-apps:/shared/apps --name shared-apps oraclelinux:8.6 /bin/bash
```
```sh
docker run -v shared-data:/shared/data --name shared-data oraclelinux:8.6 /bin/bash
```


## 3. Run Linux Desktop Image

On Linux modify and execute:
```sh
./run.sh
```
On Windows modify and execute
```bat
run.bat
```
Or via Docker CLI:
```sh
docker run -it \
 --shm-size 512m \
 --volumes-from shared-apps \
 --volumes-from shared-data \
 -p 8005:11 -p 22005:22 -p 59005:5901 \
 --name box-5 \
 --hostname box-5 \
 cameek/linux-desktop-extend:0.3
```


## 4. Known Issues

### Blurred Text

When using scale on your host system, typically 125% or 150%, the VNC session text looks blurred.

At least in browser there is a workaround - you can zoom out the page with NoVNC session:

* for 125% scaling on host desktop -> set browser zoom to 80% + set in the container display DPI from 96 to 128

* for 150% scaling on host desktop -> set browser zoom to 75% + set in the container display DPI from 96 to 128



## 5. References

https://github.com/kasmtech/workspaces-core-images

https://github.com/kasmtech/workspaces-images

https://www.digitalocean.com/community/tutorials/how-to-remotely-access-gui-applications-using-docker-and-caddy-on-debian-9

https://github.com/novnc/noVNC.git

https://hub.docker.com/r/linuxserver/rdesktop

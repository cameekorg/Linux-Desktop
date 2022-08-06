#!/bin/sh

/usr/bin/remove-nologin

##/usr/bin/startxfce4 --replace &
/usr/sbin/gdm &

/usr/libexec/vncsession-restore :1

/usr/libexec/vncsession-start :1

/usr/local/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 11 &

wait

FROM oraclelinux:8.6

# Docker Run

# External Arguments
# ------------------
ARG USER=resu
ARG PASSWORD=drowssap
ARG TIMEZONE=Europe/Prague

ARG NOVNC_VERSION="1.3.0"
ARG WEBSOCKIFY_VERSION="0.10.0"

# Environment Variables
# ---------------------
# Ref: https://github.com/snapcore/snapcraft/blob/master/Dockerfile
ENV LC_ALL C.UTF-8


# Make Systemd Functional for Docker
# ----------------------------------
# Systemd is included in Centos image, but not active by default. This Dockerfile deletes a number of unit files which might cause issues.
# Ref: https://hub.docker.com/_/centos/#Systemd-Integration
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/systemd-update-utmp*; \
    rm -f /lib/systemd/system/basic.target.wants/*; \
    rm -f /lib/systemd/system/anaconda.target.wants/*;


# Enable SSHD Service
# -------------------
RUN chkconfig sshd on


# Copy Configurations
# -------------------
COPY copy-configs /usr/local/copy-configs/


# Remove Nologin Service Fix
# --------------------------
# Handle issues with Nologin after boot.
# Ref: https://unix.stackexchange.com/questions/487742/system-is-booting-up-unprivileged-users-are-not-permitted-to-log-in-yet
RUN cp /usr/local/copy-configs/usr/bin/remove-nologin /usr/bin/remove-nologin
RUN cp /usr/local/copy-configs/etc/systemd/system/remove-nologin.service /etc/systemd/system/remove-nologin.service
RUN chmod 755 /usr/bin/remove-nologin
RUN chmod 644 /etc/systemd/system/remove-nologin.service
RUN systemctl enable remove-nologin.service


## TODO : Fix systemd-update-utmp-runlevel.servic
#[DEPEND] Dependency failed for Update UTMP about System Runlevel Changes.
#systemd-update-utmp-runlevel.service: Job systemd-update-utmp-runlevel.service/start failed with result 'dependency'.



# Install Packages - Init
# -----------------------
RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
RUN dnf update -y
RUN dnf install -y epel-release
RUN dnf install -y ca-certificates
RUN dnf install -y glibc-langpack-en
##RUN dnf --enablerepo=epel group


# Install Packages - Tools
# ------------------------
RUN dnf install -y cabextract
RUN dnf install -y fontconfig
RUN dnf install -y git
RUN dnf install -y gzip
RUN dnf install -y hostname
RUN dnf install -y mc
RUN dnf install -y netcat
RUN dnf install -y net-tools
RUN dnf install -y openssh-server
RUN dnf install -y openssh-clients
RUN dnf install -y passwd
RUN dnf install -y sudo
RUN dnf install -y tcpdump
RUN dnf install -y telnet
RUN dnf install -y tree
RUN dnf install -y unzip
RUN dnf install -y xz
RUN dnf install -y xorg-x11-font-utils
RUN dnf install -y wget


# Install Packages - XFCE Desktop
# -------------------------------
RUN dnf group install -y "Xfce"
RUN dnf install -y gnu-free-fonts-common
RUN dnf install -y gnu-free-mono-fonts
RUN dnf install -y gnu-free-sans-fonts
RUN dnf install -y gnu-free-serif-fonts
RUN dnf install -y tigervnc-server
RUN dnf remove -y xfce4-power-manager
RUN dnf remove -y xfce4-screensaver
RUN systemctl set-default graphical.target


# Add User to System
# ------------------
# Create user and set password. Add to wheel for sudo use.
RUN useradd -m -s /bin/bash ${USER}
RUN echo "${USER}:${PASSWORD}" | chpasswd
RUN usermod -aG wheel ${USER}


# User Config for VNC Server
# --------------------------
USER ${USER}
RUN mkdir /home/${USER}/.vnc
RUN echo "${PASSWORD}" | /usr/bin/vncpasswd -f > /home/${USER}/.vnc/passwd
RUN chmod 600 /home/${USER}/.vnc/passwd
USER root
RUN echo "session=xfce" >> /etc/tigervnc/vncserver-config-mandatory
RUN echo ":1=${USER}" >> /etc/tigervnc/vncserver.users
RUN systemctl enable vncserver@:1.service


# Install NoVNC
# -------------
RUN if [[ -n "${NOVNC_VERSION}" ]]; then \
    echo "Installing NoVNC version: ${NOVNC_VERSION}"; \
    pip3 install numpy; \
    git clone https://github.com/novnc/noVNC.git "/usr/local/novnc-${NOVNC_VERSION}"; \
    ln -s /usr/local/novnc-${NOVNC_VERSION} /usr/local/novnc; \
    cd /usr/local/novnc; \
    git checkout tags/v${NOVNC_VERSION}; \
    ln -s /usr/local/novnc/utils/novnc_proxy /usr/bin/novnc_proxy; \
    cp /usr/local/copy-configs/etc/systemd/system/novnc.service /etc/systemd/system/novnc.service; \
    chmod 755 /usr/local/novnc/utils/novnc_proxy; \
    chmod 644 /etc/systemd/system/novnc.service; \
    cp /usr/local/copy-configs/usr/local/novnc/index.html /usr/local/novnc/index.html; \
    systemctl enable novnc.service; \
    fi


# Install Websockify
# ------------------
RUN if [[ -n "${WEBSOCKIFY_VERSION}" ]]; then \
    echo "Installing Websockify version: ${WEBSOCKIFY_VERSION}"; \
    git clone https://github.com/novnc/websockify.git "/usr/local/websockify-${WEBSOCKIFY_VERSION}"; \
    ln -s /usr/local/websockify-${WEBSOCKIFY_VERSION} /usr/local/websockify; \
    cd /usr/local/websockify; \
    git checkout tags/v${WEBSOCKIFY_VERSION}; \
    ln -s /usr/local/websockify-${WEBSOCKIFY_VERSION} /usr/local/novnc/websockify; \
    fi


# XFCE Policy Kit Fix
# -------------------
# After every login there is Polkit tool displayed requiring login, moreover with some services disabled bellow, it crashes. Therefore it's disabled.
RUN echo "Hidden=true" >> /etc/xdg/autostart/xfce-polkit.desktop


# Disable Selected Services Fix
# -----------------------------
# Disable services installed after XFCE4 Desktop which are failing due to non-priviledged mode. Systemd-hostnamed is nested with dbus-org.freedesktop.hostname1.service.
# Upower.service is for power management. Systemd-localed has also troubles in container.
# Ref: https://github.com/systemd/systemd/issues/4122
# Ref: https://github.com/containers/podman/issues/5021
#   plymouth-start.service                loaded    failed   failed    Show Plymouth Boot Screen
#   rtkit-daemon.service                  loaded    failed   failed    RealtimeKit Scheduling Policy Service
#   systemd-hostnamed.service             loaded    failed   failed    Hostname Service
RUN systemctl mask plymouth-start.service
RUN systemctl mask rtkit-daemon.service
RUN systemctl mask systemd-hostnamed.service
RUN systemctl mask dbus-org.freedesktop.hostname1.service
RUN systemctl mask upower.service
RUN systemctl mask systemd-localed.service


# Volumes
# ------------

# Expose Ports
# ------------
EXPOSE 80
EXPOSE 22
EXPOSE 5901

# Command on Start
# ----------------
CMD [ "/usr/sbin/init" ]

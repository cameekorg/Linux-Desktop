FROM oraclelinux:8.6
LABEL description="Base Linux Desktop image which is supposed to be inherited and customized"


# External Arguments
# ------------------
ARG USER=resu
ARG PASSWORD=drowssap
ARG TIMEZONE=Europe/Paris

ARG NOVNC_VERSION="1.3.0"
ARG WEBSOCKIFY_VERSION="0.10.0"
ARG GOSU_VERSION="1.14"

ARG DEPLOY_DIR=/usr/local/deploy


# Environment Variables
# ---------------------
# Ref: https://github.com/snapcore/snapcraft/blob/master/Dockerfile
ENV LC_ALL C.UTF-8


# Copy Configurations & Scripts
# -----------------------------
COPY deploy ${DEPLOY_DIR}


# Change Timezone
# ---------------
# Ref: https://ma.ttias.be/changing-the-time-and-timezone-settings-on-centos-or-rhel/
RUN mv -f /etc/localtime /etc/localtime.backup
RUN ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime


# Init Script
# -----------
RUN cp ${DEPLOY_DIR}/usr/local/bin/init /usr/local/bin/init 
RUN chmod 500 /usr/local/bin/init


# One-time User Setup
# -------------------
RUN cp ${DEPLOY_DIR}/usr/local/bin/usersetup /usr/local/bin/usersetup 
RUN chmod 755 /usr/local/bin/usersetup


# Remove Nologin Service Fix
# --------------------------
# Handle issues with Nologin after boot.
# Ref: https://unix.stackexchange.com/questions/487742/system-is-booting-up-unprivileged-users-are-not-permitted-to-log-in-yet
RUN cp ${DEPLOY_DIR}/usr/local/bin/remove-nologin /usr/local/bin/remove-nologin
RUN chmod 755 /usr/local/bin/remove-nologin


# Install Packages - Init
# -----------------------
RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
RUN dnf update -y
RUN dnf install -y epel-release


# Install Packages - Tools
# ------------------------
RUN dnf update -y && dnf install -y \
    bzip2 \
    ca-certificates \
    cabextract \
    fontconfig \
    git \
    glibc-langpack-en \
    gzip \
    hostname \
    htop \
    mc \
    netcat \
    net-tools \
    openssh-server \
    openssh-clients \
    passwd \
    redhat-lsb \
    rsync \
    sudo \
    supervisor \
    tar \
    tcpdump \
    telnet \
    tree \
    unzip \
    wget \
    xdg-utils \
    xz \
    xorg-x11-font-utils \
    zip


# Install Packages - XFCE Desktop
# -------------------------------
RUN dnf group install -y "Xfce"
RUN dnf update -y && dnf install -y \
    gnu-free-fonts-common \
    gnu-free-mono-fonts \
    gnu-free-sans-fonts \
    gnu-free-serif-fonts \
    tigervnc-server
RUN dnf remove -y xfce4-power-manager
RUN dnf remove -y xfce4-screensaver


# XFCE Policy Kit Fix
# -------------------
# After every login there is Polkit tool displayed requiring login, moreover with some services disabled bellow, it crashes. Therefore it's disabled.
RUN echo "Hidden=true" >> /etc/xdg/autostart/xfce-polkit.desktop


# Copy Custom Backgrounds
# -----------------------
RUN cp -r ${DEPLOY_DIR}/usr/share/backgrounds/. /usr/share/backgrounds


# Copy Custom Themes
# ------------------
RUN cp -r ${DEPLOY_DIR}/usr/share/themes/. /usr/share/themes


# Copy Custom User Settings
# -------------------------
RUN cp -r ${DEPLOY_DIR}/etc/skel/. /etc/skel

# Copy Root User Settings
# -------------------------
RUN cp -r ${DEPLOY_DIR}/root/.bashrc /root/.bashrc
RUN chmod 600 /root/.bashrc


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
RUN chmod 755 /usr/libexec/vncsession-restore
RUN chmod 755 /usr/libexec/vncsession-start


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
    chmod 755 /usr/local/novnc/utils/novnc_proxy; \
    cp ${DEPLOY_DIR}/usr/local/novnc/index.html /usr/local/novnc/index.html; \
    fi


# Install Websockify
# ------------------
RUN if [[ -n "${WEBSOCKIFY_VERSION}" ]]; then \
    echo "Installing Websockify version: ${WEBSOCKIFY_VERSION}"; \
    git clone https://github.com/novnc/websockify.git "/usr/local/websockify-${WEBSOCKIFY_VERSION}"; \
    ln -s /usr/local/websockify-${WEBSOCKIFY_VERSION} /usr/local/websockify; \
    cd /usr/local/websockify; \
    git checkout tags/v${WEBSOCKIFY_VERSION}; \
    ln -s /usr/local/websockify-${WEBSOCKIFY_VERSION} /usr/local/novnc/utils/websockify; \
    fi


# Install Gosu
# ------------
# Sudo Alternative for Docker: simple tool grown out of the simple fact that su and sudo
# have very strange and often annoying TTY and signal-forwarding behavior.
RUN if [[ -n "${GOSU_VERSION}" ]]; then \
		gpg --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
		curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.14/gosu-amd64" && \
		curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.14/gosu-amd64.asc" && \
		gpg --verify /usr/local/bin/gosu.asc && \
		rm -f /usr/local/bin/gosu.asc && \
		rm -rf /root/.gnupg/ && \
		chmod +x /usr/local/bin/gosu && \
		gosu nobody true; \
    fi


# Copy Supervisord Script
# ------------------------
RUN mkdir /etc/supervisord
RUN cp ${DEPLOY_DIR}/etc/supervisord/supervisord.conf /etc/supervisord/supervisord.conf


# Volumes
# ------------


# Expose Ports
# ------------
EXPOSE 11
EXPOSE 22
EXPOSE 5901


# Command on Start
# ----------------
CMD [ "sh", "-c", "/usr/local/bin/init && exec supervisord -c /etc/supervisord/supervisord.conf" ]

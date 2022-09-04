FROM oraclelinux:8.6
LABEL description="Base Linux Desktop image which is supposed to be inherited and customized"


# External Arguments
# ------------------
ARG USER=resu
ARG PASSWORD=drowssap
ARG TIMEZONE=Europe/Paris
ARG DEPLOY_DIR=/usr/local/deploy

ARG NOVNC_VERSION="1.3.0"
ARG WEBSOCKIFY_VERSION="0.10.0"
ARG GOSU_VERSION="1.14"
ARG JAVA_VERSION="java-17-openjdk-devel.x86_64"
ARG PEAZIP_VERSION="7.9.0"
ARG MOKAICON_VERSION="moka-icon-theme-5.3.git+1475513102.0566904-8.1"
ARG MSFONTS_VERSION="2.6-1"
ARG MAVEN_VERSION="3.8.6"
ARG GRADLE_VERSION="7.5.1"


# Environment Variables
# ---------------------
# Ref: https://github.com/snapcore/snapcraft/blob/master/Dockerfile
ENV LC_ALL C.UTF-8


# Copy Configurations & Scripts (without apply)
# ---------------------------------------------
COPY deploy $DEPLOY_DIR


# Change Timezone
# ---------------
# Ref: https://ma.ttias.be/changing-the-time-and-timezone-settings-on-centos-or-rhel/
RUN mv -f /etc/localtime /etc/localtime.backup
RUN ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime


# Init Script
# -----------
RUN cp $DEPLOY_DIR/usr/local/bin/init /usr/local/bin/init
RUN chmod 500 /usr/local/bin/init


# One-time User Setup
# -------------------
RUN cp $DEPLOY_DIR/usr/local/bin/usersetup /usr/local/bin/usersetup
RUN chmod 500 /usr/local/bin/usersetup


# One-time Applications Share
# ---------------------------
RUN cp $DEPLOY_DIR/usr/local/bin/appsshare /usr/local/bin/appsshare
RUN chmod 500 /usr/local/bin/appsshare


# Remove Nologin Service Fix
# --------------------------
# Handle issues with Nologin after boot.
# Ref: https://unix.stackexchange.com/questions/487742/system-is-booting-up-unprivileged-users-are-not-permitted-to-log-in-yet
RUN cp $DEPLOY_DIR/usr/local/bin/remove-nologin /usr/local/bin/remove-nologin
RUN chmod 500 /usr/local/bin/remove-nologin


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
    qt5pas \
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
    xorg-x11-fonts-Type1 \
    xorg-x11-font-utils \
    zip


# Install Packages - XFCE Desktop
# -------------------------------
RUN dnf group install -y "Xfce"
RUN dnf update -y && dnf install -y \
    firefox \
    google-noto-sans-fonts \
    gnu-free-fonts-common \
    gnu-free-mono-fonts \
    gnu-free-sans-fonts \
    gnu-free-serif-fonts \
    liberation-fonts \
    liberation-serif-fonts \
    tigervnc-server
RUN dnf remove -y xfce4-power-manager
RUN dnf remove -y xfce4-screensaver


# XFCE Policy Kit Fix
# -------------------
# After every login there is Polkit tool displayed requiring login, moreover with some services disabled bellow, it crashes. Therefore it's disabled.
RUN echo "Hidden=true" >> /etc/xdg/autostart/xfce-polkit.desktop


# Copy Custom Backgrounds
# -----------------------
RUN cp -r $DEPLOY_DIR/usr/share/backgrounds/. /usr/share/backgrounds


# Copy Custom Themes
# ------------------
RUN cp -r $DEPLOY_DIR/usr/share/themes/. /usr/share/themes


# Copy Custom User Settings
# -------------------------
RUN cp -r $DEPLOY_DIR/etc/skel/. /etc/skel


# Copy Root User Settings
# -------------------------
RUN cp -r $DEPLOY_DIR/root/.bashrc /root/.bashrc
RUN chmod 600 /root/.bashrc


# Add User to System
# ------------------
# Create user and set password. Add to wheel for sudo use.
RUN useradd -m -s /bin/bash $USER
RUN echo "$USER:$PASSWORD" | chpasswd
RUN usermod -aG wheel $USER


# User Config for VNC Server
# --------------------------
USER $USER
RUN mkdir /home/$USER/.vnc
RUN echo "$PASSWORD" | /usr/bin/vncpasswd -f > /home/$USER/.vnc/passwd
RUN chmod 600 /home/$USER/.vnc/passwd
USER root
RUN echo "session=xfce" >> /etc/tigervnc/vncserver-config-mandatory
RUN echo ":1=$USER" >> /etc/tigervnc/vncserver.users
RUN chmod 750 /usr/libexec/vncsession-restore
RUN chmod 750 /usr/libexec/vncsession-start


# Install NoVNC
# -------------
RUN if [[ -n "$NOVNC_VERSION" ]]; then \
    echo "Installing NoVNC version: $NOVNC_VERSION"; \
    pip3 install numpy; \
    git clone https://github.com/novnc/noVNC.git "/usr/local/novnc-$NOVNC_VERSION"; \
    ln -s /usr/local/novnc-$NOVNC_VERSION /usr/local/novnc; \
    cd /usr/local/novnc; \
    git checkout tags/v$NOVNC_VERSION; \
    ln -s /usr/local/novnc/utils/novnc_proxy /usr/bin/novnc_proxy; \
    chmod 750 /usr/local/novnc/utils/novnc_proxy; \
    cp $DEPLOY_DIR/usr/local/novnc/index.html /usr/local/novnc/index.html; \
    fi


# Install Websockify
# ------------------
RUN if [[ -n "$WEBSOCKIFY_VERSION" ]]; then \
    echo "Installing Websockify version: $WEBSOCKIFY_VERSION"; \
    git clone https://github.com/novnc/websockify.git "/usr/local/websockify-$WEBSOCKIFY_VERSION"; \
    ln -s /usr/local/websockify-$WEBSOCKIFY_VERSION /usr/local/websockify; \
    cd /usr/local/websockify; \
    git checkout tags/v$WEBSOCKIFY_VERSION; \
    ln -s /usr/local/websockify-$WEBSOCKIFY_VERSION /usr/local/novnc/utils/websockify; \
    fi


# Install Gosu
# ------------
# Sudo Alternative for Docker: simple tool grown out of the simple fact that su and sudo
# have very strange and often annoying TTY and signal-forwarding behavior.
RUN if [[ -n "$GOSU_VERSION" ]]; then \
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
RUN cp $DEPLOY_DIR/etc/supervisord/supervisord.conf /etc/supervisord/supervisord.conf


# Install Java
# ------------
RUN if [[ -n "$JAVA_VERSION" ]]; then \
        dnf install -y $JAVA_VERSION && \
        echo "export JAVA_HOME=/etc/alternatives/java_sdk_openjdk" >> /etc/profile.d/java.sh && \
        chmod 644 /etc/profile.d/java.sh ; \
    fi


# Install Maven
# -------------
RUN if [[ -n "$MAVEN_VERSION" ]]; then \
        wget https://dlcdn.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
        mkdir -p /opt/versions/maven/ && \
        tar xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt/versions/maven/ && \
        ln -s /opt/versions/maven/apache-maven-$MAVEN_VERSION /opt/maven && \
        echo "export M2_HOME=/opt/maven" >> /etc/profile.d/maven.sh && \
        echo "export PATH=\$M2_HOME/bin:\$PATH" >> /etc/profile.d/maven.sh && \
        chmod 644 /etc/profile.d/maven.sh && \
        rm -rf apache-maven-${MAVEN_VERSION}-bin.tar.gz ; \
    fi


# Install Gradle
# --------------
RUN if [[ -n "$GRADLE_VERSION" ]]; then \
        wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip && \
        mkdir -p /opt/versions/gradle/ && \
        unzip gradle-${GRADLE_VERSION}-all.zip -d /opt/versions/gradle/ && \
        ln -s /opt/versions/gradle/gradle-$GRADLE_VERSION /opt/gradle && \
        echo "export GRADLE_HOME=/opt/gradle" >> /etc/profile.d/gradle.sh && \
        echo "export PATH=\$GRADLE_HOME/bin:\$PATH" >> /etc/profile.d/gradle.sh && \
        chmod 644 /etc/profile.d/gradle.sh && \
        rm -rf gradle-${GRADLE_VERSION}-all.zip ; \
    fi


# Install PeaZip
# --------------
RUN if [[ -n "$PEAZIP_VERSION" ]]; then \
        wget -c http://sourceforge.net/projects/peazip/files/$PEAZIP_VERSION/peazip-$PEAZIP_VERSION.LINUX.Qt5-1.x86_64.rpm && \
        sudo rpm -i peazip-$PEAZIP_VERSION.LINUX.Qt5-1.x86_64.rpm && \
        rm -f peazip-$PEAZIP_VERSION.LINUX.Qt5-1.x86_64.rpm ; \
    fi


# Install Moka Icons Set
# ----------------------
RUN if [[ -n "$MOKAICON_VERSION" ]]; then \
        dnf install -y https://download.opensuse.org/repositories/home:/snwh:/moka/openSUSE_13.1/noarch/$MOKAICON_VERSION.noarch.rpm  && \
        gtk-update-icon-cache /usr/share/icons/Moka/ ; \
	fi


# Install Microsoft Fonts
# -----------------------
# Ref: https://www.fosslinux.com/42406/how-to-install-microsoft-truetype-fonts-on-fedora.htm
RUN if [[ -n "$MSFONTS_VERSION" ]]; then \
        rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-$MSFONTS_VERSION.noarch.rpm ; \
    fi


# Expose Ports
# ------------
EXPOSE 11
EXPOSE 22
EXPOSE 5901


# Command on Start
# ----------------
CMD [ "sh", "-c", "/usr/local/bin/init && exec supervisord -c /etc/supervisord/supervisord.conf" ]

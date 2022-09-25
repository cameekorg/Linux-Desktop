FROM cameek/linux-desktop-base:0.3
LABEL description="Extended Linux Desktop image"

# External Arguments
# ------------------
ARG DEPLOY_DIR=/usr/local/deploy

ARG CHROME_VERSION="latest"
ARG EDGE_VERSION="latest"
ARG JD_GUI_VERSION="1.6.6"
ARG ECLIPSE_JEE_DOWNLOAD_VERSION="2022-09/R/eclipse-jee-2022-09-R-linux-gtk-x86_64.tar.gz"
# List Eclipse versions here:
# https://ftp.snt.utwente.nl/pub/software/eclipse/technology/epp/downloads/release/

#ARG MOKAICON_VERSION="openSUSE_Tumbleweed/noarch/moka-icon-theme-5.3.git+1475513102.0566904-8.36"
#ARG MOKAICONDIST_VERSION="2.20190530gitc0355ea.fc30"
#ARG MSFONTS_VERSION="2.6-1"


# Copy Configurations & Scripts (without apply)
# ---------------------------------------------
COPY deploy $DEPLOY_DIR


## Install Chrome
## --------------
RUN if [[ -n "$CHROME_VERSION" ]]; then \
        echo "1. Installing: Google Chrome $CHROME_VERSION" && \
        cp $DEPLOY_DIR/etc/yum.repos.d/google-chrome.repo /etc/yum.repos.d/google-chrome.repo && \
        chmod 750 /etc/yum.repos.d/google-chrome.repo && \
        dnf update -y && \
        dnf install -y google-chrome-stable && \
        echo "2. Creating structure: /opt/versions/chrome/chrome-$CHROME_VERSION" && \
        mkdir -p /opt/versions/chrome/chrome-$CHROME_VERSION && \
        echo "3. Moving there: /opt/google/chrome/*" && \
        mv /opt/google/chrome/* /opt/versions/chrome/chrome-$CHROME_VERSION && \
        echo "4. Creating symlink: /opt/chrome -> /opt/versions/chrome/chrome-$CHROME_VERSION" && \
        ln -sn /opt/versions/chrome/chrome-$CHROME_VERSION /opt/chrome && \
        echo "5. Removing old directory: /opt/google/chrome" && \
        rm -rf /opt/google/chrome && \
        echo "5. Creating back-compatible symlink: /opt/chrome -> /opt/versions/chrome/chrome-$CHROME_VERSION" && \
        ln -sn /opt/chrome /opt/google/chrome && \
        echo "6. Overwriting default shell script" && \
        mv /usr/bin/google-chrome-stable /usr/bin/google-chrome-orig && \
        cp $DEPLOY_DIR/usr/bin/google-chrome-stable /usr/bin/google-chrome-stable && \
        chmod 755 /usr/bin/google-chrome-stable && \
        echo "7. Creating default policies" && \
        mkdir -p /etc/opt/chrome/policies/managed/ && \
        cp $DEPLOY_DIR/etc/opt/chrome/policies/managed/default_managed_policy.json /etc/opt/chrome/policies/managed/default_managed_policy.json && \
        chmod 750 $DEPLOY_DIR/etc/opt/chrome/policies/managed/default_managed_policy.json && \
        touch /opt/chrome/chrome-$CHROME_VERSION.version ; \
    fi


## Install Edge
## --------------
RUN if [[ -n "$EDGE_VERSION" ]]; then \
        echo "1. Installing: Microsoft Edge $EDGE_VERSION" && \
        cp $DEPLOY_DIR/etc/yum.repos.d/edge.repo /etc/yum.repos.d/edge.repo && \
        chmod 750 /etc/yum.repos.d/edge.repo && \
        dnf update -y && \
        dnf install -y microsoft-edge-stable && \
        echo "2. Creating structure: /opt/versions/msedge/msedge-$EDGE_VERSION" && \
        mkdir -p /opt/versions/msedge/msedge-$EDGE_VERSION && \
        echo "3. Moving there: /opt/microsoft/msedge/*" && \
        mv /opt/microsoft/msedge/* /opt/versions/msedge/msedge-$EDGE_VERSION && \
        echo "4. Creating symlink: /opt/msedge -> /opt/versions/msedge/msedge-$EDGE_VERSION" && \
        ln -sn /opt/versions/msedge/msedge-$EDGE_VERSION /opt/msedge && \
        echo "5. Removing old directory: /opt/microsoft/msedge" && \
        rm -rf /opt/microsoft/msedge && \
        echo "5. Creating back-compatible symlink: /opt/msedge -> /opt/versions/msedge/msedge-$EDGE_VERSION" && \
        ln -sn /opt/msedge /opt/microsoft/msedge && \
        echo "6. Overwriting default shell script" && \
        mv /usr/bin/microsoft-edge-stable /usr/bin/microsoft-edge-orig && \
        cp $DEPLOY_DIR/usr/bin/microsoft-edge-stable /usr/bin/microsoft-edge-stable && \
        chmod 755 /usr/bin/microsoft-edge-stable && \
        echo "7. Creating default policies" && \
        mkdir -p /etc/opt/edge/policies/managed/ && \
        cp $DEPLOY_DIR/etc/opt/edge/policies/managed/default_managed_policy.json /etc/opt/edge/policies/managed/default_managed_policy.json && \
        chmod 750 $DEPLOY_DIR/etc/opt/edge/policies/managed/default_managed_policy.json && \
        touch /opt/msedge/msedge-$EDGE_VERSION.version ; \
    fi


# Install Java Decompiler
# -----------------------
RUN if [[ -n "$JD_GUI_VERSION" ]]; then \
        echo "1. Downloading: jd-gui-$JD_GUI_VERSION" && \
        wget https://github.com/java-decompiler/jd-gui/releases/download/v$JD_GUI_VERSION/jd-gui-$JD_GUI_VERSION.jar && \
        echo "2. Creating structure: /opt/versions/jd-gui/jd-gui-$JD_GUI_VERSION" && \
        mkdir -p /opt/versions/jd-gui/jd-gui-$JD_GUI_VERSION && \
        echo "3. Creating symlink: /opt/jd-gui -> /opt/versions/jd-gui/jd-gui-$JD_GUI_VERSION" && \
        ln -sn /opt/versions/jd-gui/jd-gui-$JD_GUI_VERSION /opt/jd-gui && \
        echo "4. Moving there: jd-gui-$JD_GUI_VERSION.jar > /opt/jd-gui/jd-gui.jar" && \
        mv jd-gui-$JD_GUI_VERSION.jar /opt/jd-gui/jd-gui.jar && \
        echo "5. Coping there additional files like jd-gui.desktop" && \
        cp $DEPLOY_DIR/opt/jd-gui/* /opt/jd-gui && \
        echo "6. Setting permissions" && \
        chmod 755 /opt/jd-gui/jd-gui && \
        chmod 755 /opt/jd-gui/jd-gui.jar && \
        chmod 644 /opt/jd-gui/jd-gui.desktop && \
        echo "7. Adding to menu: jd-gui.desktop" && \
        ln -sn /opt/jd-gui/jd-gui.desktop /usr/share/applications/jd-gui.desktop && \
        echo "8. Storing version info" && \
        touch /opt/jd-gui/jd-gui-$JD_GUI_VERSION.version ; \
    fi


# Install Eclipse JEE
# --------------------
RUN if [[ -n "$ECLIPSE_JEE_DOWNLOAD_VERSION" ]]; then \
        ECLIPSE_JEE_FILE=${ECLIPSE_JEE_DOWNLOAD_VERSION##*/} && \
        ECLIPSE_JEE_VERSION=${ECLIPSE_JEE_FILE%.*.*} && \
        echo "1. Downloading: $ECLIPSE_JEE_VERSION" && \
        wget https://mirrors.xmission.com/eclipse/technology/epp/downloads/release/$ECLIPSE_JEE_DOWNLOAD_VERSION && \
        echo "" && \
        echo "2. Creating parent structure: /opt/versions/eclipse-jee" && \
        mkdir -p /opt/versions/eclipse-jee && \
        echo "" && \
        echo "3. Unpacking there: $ECLIPSE_JEE_FILE > /opt/versions/eclipse-jee" && \
        tar -xzvf $ECLIPSE_JEE_FILE -C /opt/versions/eclipse-jee && \
        echo "" && \
        echo "4. Renaming: /opt/versions/eclipse-jee/eclipse > /opt/versions/eclipse-jee/$ECLIPSE_JEE_VERSION" && \
        mv /opt/versions/eclipse-jee/eclipse /opt/versions/eclipse-jee/$ECLIPSE_JEE_VERSION && \
        echo "" && \
        echo "5. Creating symlink: /opt/eclipse-jee -> /opt/versions/eclipse-jee/$ECLIPSE_JEE_VERSION" && \
        ln -sn /opt/versions/eclipse-jee/$ECLIPSE_JEE_VERSION /opt/eclipse-jee && \
        echo "" && \
        echo "6. Coping there additional files like eclipse-jee.desktop" && \
        cp $DEPLOY_DIR/opt/eclipse-jee/* /opt/eclipse-jee && \
        echo "" && \
        echo "7. Setting permissions" && \
        chmod 644 /opt/eclipse-jee/eclipse-jee.desktop && \
        echo "" && \
        echo "8. Adding to menu: eclipse-jee.desktop" && \
        ln -sn /opt/eclipse-jee/eclipse-jee.desktop /usr/share/applications/eclipse-jee.desktop && \
        echo "" && \
        echo "9. Cleaning old files" && \
        rm $ECLIPSE_JEE_FILE && \
        echo "" && \
        echo "10. Storing version info" && \
        touch /opt/eclipse-jee/$ECLIPSE_JEE_VERSION.version && \
        echo "" ; \
    fi


# Expose Ports
# ------------
EXPOSE 11
EXPOSE 22
EXPOSE 5901

# Command on Start
# ----------------
CMD [ "sh", "-c", "/usr/local/bin/init && exec supervisord -c /etc/supervisord/supervisord.conf" ]

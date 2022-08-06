FROM cameek/linux-desktop-base:0.1
LABEL description="Extended Linux Desktop image"

# External Arguments
# ------------------
ARG NOVNC_VERSION="1.3.0"
ARG WEBSOCKIFY_VERSION="0.10.0"
ARG GOSU_VERSION="1.14"
ARG PEAZIP_VERSION="7.9.0"


# Copy Configurations & Scripts
# -----------------------------
COPY deploy /usr/local/deploy

# Install Packages - Tools
# ------------------------
RUN dnf update -y && dnf install -y \
    qt5pas

# Install PeaZip
# --------------
RUN if [[ -n "${PEAZIP_VERSION}" ]]; then \
        wget -c http://sourceforge.net/projects/peazip/files/${PEAZIP_VERSION}/peazip-${PEAZIP_VERSION}.LINUX.GTK2-1.x86_64.rpm && \
        sudo rpm -i peazip-${PEAZIP_VERSION}.LINUX.GTK2-1.x86_64.rpm && \
        rm -f peazip-${PEAZIP_VERSION}.LINUX.GTK2-1.x86_64.rpm ; \
    fi

# Expose Ports
# ------------
EXPOSE 11
EXPOSE 22
EXPOSE 5901

# Command on Start
# ----------------
CMD [ "sh", "-c", "/usr/local/bin/init && exec supervisord -c /etc/supervisord/supervisord.conf" ]

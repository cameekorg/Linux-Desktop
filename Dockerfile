FROM cameek/linux-desktop-base:0.1
LABEL description="Extended Linux Desktop image"

# External Arguments
# ------------------
ARG PEAZIP_VERSION="7.9.0"
ARG MOKAICON_VERSION="openSUSE_Tumbleweed/noarch/moka-icon-theme-5.3.git+1475513102.0566904-8.36"
ARG MOKAICONDIST_VERSION="2.20190530gitc0355ea.fc30"
ARG MSFONTS_VERSION="2.6-1"


# Copy Configurations & Scripts
# -----------------------------
COPY deploy /usr/local/deploy

# Install Packages - Tools
# ------------------------
RUN dnf update -y && dnf install -y \
    firefox \
    qt5pas

# Install PeaZip
# --------------
RUN if [[ -n "${PEAZIP_VERSION}" ]]; then \
        wget -c http://sourceforge.net/projects/peazip/files/${PEAZIP_VERSION}/peazip-${PEAZIP_VERSION}.LINUX.Qt5-1.x86_64.rpm && \
        sudo rpm -i peazip-${PEAZIP_VERSION}.LINUX.Qt5-1.x86_64.rpm && \
        rm -f peazip-${PEAZIP_VERSION}.LINUX.Qt5-1.x86_64.rpm ; \
    fi

# Install Moka Icons Set
# ----------------------
# Ref: https://software.opensuse.org/download.html?project=home%3Asnwh%3Amoka&package=moka-icon-theme
RUN if [[ -n "${MOKAICON_VERSION}" ]]; then \
        dnf install -y https://download.opensuse.org/repositories/home:/snwh:/moka/${MOKAICON_VERSION}.noarch.rpm && \
        gtk-update-icon-cache /usr/share/icons/Moka/ ; \
	fi

# Install Microsoft Fonts
# -----------------------
# Ref: https://www.fosslinux.com/42406/how-to-install-microsoft-truetype-fonts-on-fedora.htm
RUN if [[ -n "${MOKAICON_VERSION}" ]]; then \
        rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm ; \
    fi

# Expose Ports
# ------------
EXPOSE 11
EXPOSE 22
EXPOSE 5901

# Command on Start
# ----------------
CMD [ "sh", "-c", "/usr/local/bin/init && exec supervisord -c /etc/supervisord/supervisord.conf" ]

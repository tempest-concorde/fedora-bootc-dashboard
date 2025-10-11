FROM quay.io/fedora/fedora-bootc:42
# Install packages for Firefox kiosk setup

# Add Tailscale repository (direct download for dnf5 compatibility)
RUN curl -fsSL https://pkgs.tailscale.com/stable/fedora/tailscale.repo -o /etc/yum.repos.d/tailscale.repo
RUN dnf install -y gnome-shell gnome-kiosk gnome-kiosk-script-session \
firefox unzip alsa-sof-firmware python python-pip gcc python-devel \
xorg-x11-xinit gdm chrony at podman tailscale curl jq \
pciutils usbutils aircrack-ng tmux && \
dnf clean all

# Note: kiosk user and GDM autologin configuration handled by kickstart

# Create template directories for kiosk configuration (ownership set by kickstart)
RUN mkdir -p /var/home/kiosk/.config/autostart && \
    mkdir -p /var/home/kiosk/.mozilla/firefox

# Copy Firefox kiosk configuration to bootc home directory
COPY firefox-kiosk.desktop /var/home/kiosk/.config/autostart/
COPY firefox-kiosk.desktop /etc/xdg/autostart/
COPY firefox-kiosk.sh /usr/local/bin/
COPY kiosk-session.sh /usr/local/bin/
COPY user.js /var/home/kiosk/.mozilla/firefox/

# Copy Firefox systemd user service
COPY firefox-kiosk.service /etc/systemd/user/

# Copy system-level configurations
COPY firefox-watchdog.sh /usr/local/bin/
COPY firefox-watchdog.service /etc/systemd/system/
COPY firefox-watchdog.timer /etc/systemd/system/
COPY kiosk-manager.service /etc/systemd/system/
COPY kiosk-manager.sh /usr/local/bin/
COPY kiosk-debug.sh /usr/local/bin/

# Copy GDM configuration
COPY gdm-custom.conf /etc/gdm/custom.conf

# Copy dconf configuration for login screen
RUN mkdir -p /etc/dconf/db/gdm.d
COPY 00-login-screen /etc/dconf/db/gdm.d/

# Copy screen lock disable configuration
RUN mkdir -p /etc/dconf/db/local.d
COPY disable-screen-lock.conf /etc/dconf/db/local.d/

# Create directories for monitoring configurations
RUN mkdir -p /etc/containers/systemd && \
    mkdir -p /etc/prometheus

# Copy Quadlet configuration files for monitoring stack
COPY prometheus.container /etc/containers/systemd/
COPY perses.container /etc/containers/systemd/
COPY node-exporter.container /etc/containers/systemd/
COPY monitoring.network /etc/containers/systemd/

# Copy monitoring configuration files
COPY prometheus.yml /etc/prometheus/

# Set permissions for scripts and enable services
RUN chmod +x /usr/local/bin/firefox-kiosk.sh && \
chmod +x /usr/local/bin/kiosk-session.sh && \
chmod +x /usr/local/bin/firefox-watchdog.sh && \
chmod +x /usr/local/bin/kiosk-manager.sh && \
chmod +x /usr/local/bin/kiosk-debug.sh && \
systemctl enable gdm && \
systemctl enable chronyd && \
systemctl enable firefox-watchdog.timer && \
systemctl enable kiosk-manager.service && \
systemctl enable tailscaled && \
systemctl enable sshd && \
dconf update

# Note: kiosk user creation and home directory setup handled by kickstart

RUN bootc container lint

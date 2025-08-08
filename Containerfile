FROM quay.io/fedora/fedora-bootc:42
# Install packages for Firefox kiosk setup

RUN dnf install -y gnome-shell gnome-kiosk gnome-kiosk-script-session \
firefox unzip alsa-sof-firmware python python-pip gcc python-devel \
xorg-x11-xinit gdm chrony at && \
dnf clean all

# Note: kiosk user and GDM autologin configuration handled by kickstart

# Create template directories for kiosk configuration (ownership set by kickstart)
RUN mkdir -p /var/home/kiosk/.config/autostart && \
    mkdir -p /var/home/kiosk/.mozilla/firefox

# Copy Firefox kiosk configuration to bootc home directory
COPY firefox-kiosk.desktop /var/home/kiosk/.config/autostart/
COPY firefox-kiosk.sh /usr/local/bin/
COPY kiosk-session.sh /usr/local/bin/
COPY user.js /var/home/kiosk/.mozilla/firefox/

# Create systemd timer for automatic shutdown
COPY shutdown-timer.service /etc/systemd/system/
COPY shutdown-timer.timer /etc/systemd/system/
COPY shutdown.target /etc/systemd/system/

# Copy Firefox systemd user service
COPY firefox-kiosk.service /etc/systemd/user/

# Copy system-level configurations
COPY firefox-watchdog.sh /usr/local/bin/
COPY firefox-watchdog.service /etc/systemd/system/
COPY firefox-watchdog.timer /etc/systemd/system/

# Copy GDM configuration
COPY gdm-custom.conf /etc/gdm/custom.conf

# Copy dconf configuration for login screen
RUN mkdir -p /etc/dconf/db/gdm.d
COPY 00-login-screen /etc/dconf/db/gdm.d/

# Set permissions for scripts and enable services
RUN chmod +x /usr/local/bin/firefox-kiosk.sh && \
chmod +x /usr/local/bin/kiosk-session.sh && \
chmod +x /usr/local/bin/firefox-watchdog.sh && \
systemctl enable gdm && \
systemctl enable shutdown-timer.timer && \
systemctl enable chronyd && \
systemctl enable firefox-watchdog.timer && \
systemctl enable sshd && \
dconf update

# Note: kiosk user creation and home directory setup handled by kickstart

RUN bootc container lint

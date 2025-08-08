FROM quay.io/fedora/fedora-bootc:42
# Install packages for Firefox kiosk setup

RUN dnf install -y gnome-shell gnome-kiosk gnome-kiosk-script-session \
firefox unzip alsa-sof-firmware python python-pip gcc python-devel \
xorg-x11-xinit gdm systemd-timesyncd at && \
dnf clean all

# Note: kiosk user and GDM autologin configuration handled by kickstart

# Create template directories for kiosk configuration (ownership set by kickstart)
RUN mkdir -p /var/home/kiosk/.config/autostart && \
mkdir -p /var/home/kiosk/.mozilla/firefox

# Copy Firefox kiosk configuration to bootc home directory
COPY firefox-kiosk.desktop /var/home/kiosk/.config/autostart/
COPY firefox-kiosk.sh /usr/local/bin/
COPY user.js /var/home/kiosk/.mozilla/firefox/

# Create systemd timer for automatic shutdown
COPY shutdown-timer.service /etc/systemd/system/
COPY shutdown-timer.timer /etc/systemd/system/
COPY shutdown.target /etc/systemd/system/

# Note: first-boot setup handled by kickstart %post section

# Set permissions for Firefox kiosk script
RUN chmod +x /usr/local/bin/firefox-kiosk.sh
# Note: kiosk user ownership and service enablement handled by kickstart

RUN bootc container lint

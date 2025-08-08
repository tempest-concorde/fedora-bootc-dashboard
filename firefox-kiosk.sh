#!/bin/bash

# Firefox Kiosk Script
# This script launches Firefox in kiosk mode with two tabs

# Default webpages - can be overridden by environment variables
KIOSK_URL_1="${KIOSK_URL_1:-https://www.redhat.com}"
KIOSK_URL_2="${KIOSK_URL_2:-https://fedoraproject.org}"

# For backward compatibility, if KIOSK_URL is set, use it as the first tab
if [ -n "${KIOSK_URL}" ] && [ "${KIOSK_URL}" != "https://www.redhat.com" ]; then
    KIOSK_URL_1="${KIOSK_URL}"
fi

# Wait for the desktop environment to be ready
sleep 5

# Disable screen saver and power management
xset s off
xset s noblank
xset -dpms

# Create Firefox profile if it doesn't exist (bootc uses /var/home/)
PROFILE_DIR="/var/home/kiosk/.mozilla/firefox/kiosk-profile"
if [ ! -d "$PROFILE_DIR" ]; then
    mkdir -p "$PROFILE_DIR"
    cp /var/home/kiosk/.mozilla/firefox/user.js "$PROFILE_DIR/"
fi

# Launch Firefox in kiosk mode with two tabs
exec firefox \
    --profile "$PROFILE_DIR" \
    --kiosk \
    --no-remote \
    --disable-restore-session-state \
    --disable-background-timer-throttling \
    --disable-backgrounding-occluded-windows \
    --disable-renderer-backgrounding \
    --disable-features=TranslateUI \
    --disable-component-extensions-with-background-pages \
    --disable-extensions \
    --disable-plugins \
    --no-first-run \
    --no-default-browser-check \
    --new-tab \
    "$KIOSK_URL_1" \
    "$KIOSK_URL_2"
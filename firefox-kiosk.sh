#!/bin/bash

# Firefox Kiosk Script
# This script launches Firefox in kiosk mode to a specified webpage

# Default webpage - can be overridden by environment variable
KIOSK_URL="${KIOSK_URL:-https://www.redhat.com}"

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

# Launch Firefox in kiosk mode
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
    --homepage="$KIOSK_URL" \
    "$KIOSK_URL"
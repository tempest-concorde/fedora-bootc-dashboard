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

# Detect session type (Wayland vs X11)
SESSION_TYPE="${XDG_SESSION_TYPE:-}"
if [ -z "$SESSION_TYPE" ] && [ -n "$WAYLAND_DISPLAY" ]; then
    SESSION_TYPE="wayland"
fi
if [ -z "$SESSION_TYPE" ] && [ -n "$DISPLAY" ]; then
    SESSION_TYPE="x11"
fi

# Prefer Wayland when available for Firefox
if [ "$SESSION_TYPE" = "wayland" ]; then
    export MOZ_ENABLE_WAYLAND=1
fi

# Wait for the desktop environment to be ready
sleep 15

# Ensure DISPLAY is set only for X11
if [ "$SESSION_TYPE" != "wayland" ]; then
    export DISPLAY="${DISPLAY:-:0}"
fi

if [ "$SESSION_TYPE" != "wayland" ]; then
    # Wait for X server to be ready with timeout
    echo "Waiting for X server to be ready..."
    timeout=60
    while [ $timeout -gt 0 ] && ! xset q &>/dev/null; do
        echo "X server not ready, waiting... ($timeout seconds left)"
        sleep 2
        timeout=$((timeout-2))
    done

    if [ $timeout -le 0 ]; then
        echo "ERROR: X server failed to start within 60 seconds"
        exit 1
    fi
else
    echo "Wayland session detected; skipping X server readiness checks"
fi

# Wait for GNOME to be ready with timeout
echo "Waiting for GNOME Shell to be ready..."
timeout=60
while [ $timeout -gt 0 ] && ! pgrep -x gnome-shell &>/dev/null; do
    echo "GNOME Shell not ready, waiting... ($timeout seconds left)"
    sleep 2
    timeout=$((timeout-2))
done

if [ $timeout -le 0 ]; then
    echo "ERROR: GNOME Shell failed to start within 60 seconds"
    exit 1
fi

# Additional wait for desktop to fully load
echo "Desktop environment ready, waiting for full initialization..."
sleep 10

# Disable screen saver and power management (X11 only)
if [ "$SESSION_TYPE" != "wayland" ]; then
    xset s off
    xset s noblank
    xset -dpms
fi

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
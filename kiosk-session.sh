#!/bin/bash

# Kiosk Session Startup Script
# This script runs when the kiosk user logs in and starts Firefox

# Set environment
export DISPLAY=:0
export KIOSK_URL_1="${KIOSK_URL_1:-https://www.redhat.com}"
export KIOSK_URL_2="${KIOSK_URL_2:-https://fedoraproject.org}"

# Log startup
echo "$(date): Kiosk session starting" >> /var/log/kiosk-session.log

# Wait for desktop to be ready
sleep 15

# Disable screen saver and power management
xset s off 2>/dev/null || true
xset s noblank 2>/dev/null || true  
xset -dpms 2>/dev/null || true

# Launch Firefox kiosk
echo "$(date): Starting Firefox kiosk" >> /var/log/kiosk-session.log
exec /usr/local/bin/firefox-kiosk.sh
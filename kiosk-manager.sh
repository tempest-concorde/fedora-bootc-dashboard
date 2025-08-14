#!/bin/bash

# Kiosk Manager Script
# Ensures the kiosk user is logged in and Firefox is running

set -euo pipefail

LOG_FILE="/var/log/kiosk-manager.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [kiosk-manager] $*" >> "$LOG_FILE"
}

log "Kiosk Manager starting..."

# Wait for display manager to be ready
while ! systemctl is-active --quiet gdm; do
    log "Waiting for GDM to be active..."
    sleep 5
done

# Wait a bit more for the session to stabilize
sleep 30

# Check if kiosk user has an active session
check_kiosk_session() {
    if loginctl list-sessions --no-legend | grep -q kiosk; then
        log "Kiosk user has active session"
        return 0
    else
        log "Kiosk user does not have active session"
        return 1
    fi
}

# Check if Firefox is running for kiosk user
check_firefox_running() {
    if pgrep -u kiosk firefox >/dev/null 2>&1; then
        log "Firefox is running for kiosk user"
        return 0
    else
        log "Firefox is not running for kiosk user"
        return 1
    fi
}

# Main monitoring loop
while true; do
    log "Checking kiosk status..."
    
    # Check if kiosk user has a session
    if ! check_kiosk_session; then
        log "Kiosk user session missing, waiting for auto-login..."
        sleep 30
        continue
    fi
    
    # Check if Firefox is running
    if ! check_firefox_running; then
        log "Firefox not running, attempting to start..."
        
        # Resolve kiosk UID and runtime dir dynamically
        KIOSK_UID=$(id -u kiosk 2>/dev/null || echo "")
        if [ -z "$KIOSK_UID" ]; then
            log "Failed to determine kiosk UID"
            sleep 20
            continue
        fi
        RUNTIME_DIR="/run/user/${KIOSK_UID}"
        
        # Try to start Firefox as kiosk user (DISPLAY may be set by session; do not force for Wayland)
        su - kiosk -c "
            export XDG_RUNTIME_DIR=${RUNTIME_DIR}
            /usr/local/bin/firefox-kiosk.sh > /var/log/kiosk-session.log 2>&1 & disown
        " || log "Failed to start Firefox"
        
        # Give it time to start
        sleep 20
    fi
    
    # Wait before next check
    sleep 60
done
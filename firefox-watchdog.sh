#!/bin/bash
# Firefox watchdog - ensures Firefox is running for kiosk user
sleep 30
if ! pgrep -u kiosk firefox >/dev/null 2>&1; then
    echo "$(date): Firefox not running for kiosk user, starting..." >> /var/log/kiosk-session.log
    su - kiosk -c "DISPLAY=:0 /usr/local/bin/firefox-kiosk.sh" >/dev/null 2>&1 &
fi
#!/bin/bash

# Kiosk Debug and Diagnostic Script
# This comprehensive script provides detailed information about the kiosk system state

echo "=== KIOSK SYSTEM DIAGNOSTIC ==="
echo "Timestamp: $(date)"
echo "Hostname: $(hostname)"
echo "Uptime: $(uptime)"
echo

echo "=== USER AND SESSION STATUS ==="
echo "Current user: $(whoami)"
echo
echo "Kiosk user exists:"
getent passwd kiosk && echo "✓ Kiosk user found" || echo "✗ Kiosk user missing"
echo
echo "Active sessions:"
loginctl list-sessions --no-legend || echo "No active sessions"
echo
echo "Kiosk user session details:"
loginctl show-user kiosk 2>/dev/null || echo "Kiosk user has no session"
echo
echo "Kiosk user processes:"
ps aux | grep "^kiosk" || echo "No processes running as kiosk user"
echo

echo "=== SERVICE STATUS ==="
echo "GDM service:"
systemctl is-active gdm && echo "✓ GDM is active" || echo "✗ GDM is inactive"
systemctl is-enabled gdm && echo "✓ GDM is enabled" || echo "✗ GDM is disabled"
echo
echo "Kiosk Manager service:"
systemctl is-active kiosk-manager.service && echo "✓ Kiosk Manager is active" || echo "✗ Kiosk Manager is inactive"
systemctl is-enabled kiosk-manager.service && echo "✓ Kiosk Manager is enabled" || echo "✗ Kiosk Manager is disabled"
echo "Kiosk Manager detailed status:"
systemctl status kiosk-manager.service --no-pager -l
echo
echo "Firefox watchdog timer:"
systemctl is-active firefox-watchdog.timer && echo "✓ Firefox watchdog is active" || echo "✗ Firefox watchdog is inactive"
systemctl is-enabled firefox-watchdog.timer && echo "✓ Firefox watchdog is enabled" || echo "✗ Firefox watchdog is disabled"
echo
echo "Firefox user service (as kiosk user):"
sudo -u kiosk systemctl --user is-active firefox-kiosk.service 2>/dev/null && echo "✓ Firefox user service is active" || echo "✗ Firefox user service is inactive"
sudo -u kiosk systemctl --user is-enabled firefox-kiosk.service 2>/dev/null && echo "✓ Firefox user service is enabled" || echo "✗ Firefox user service is disabled"
echo "Firefox user service detailed status:"
sudo -u kiosk systemctl --user status firefox-kiosk.service --no-pager -l 2>/dev/null || echo "Cannot access Firefox user service"
echo
echo "All kiosk-related services:"
systemctl list-units --all | grep -E "(kiosk|firefox)" || echo "No kiosk services found"
echo

echo "=== DISPLAY STATUS ==="
echo "Display environment:"
echo "DISPLAY: ${DISPLAY:-not set}"
echo "XDG_SESSION_TYPE: ${XDG_SESSION_TYPE:-not set}"
echo
echo "X server status:"
if xset q &>/dev/null; then
    echo "✓ X server is running"
    xset q | head -5
else
    echo "✗ X server is not accessible"
fi
echo
echo "GNOME Shell status:"
if pgrep -x gnome-shell &>/dev/null; then
    echo "✓ GNOME Shell is running"
    echo "GNOME Shell processes:"
    pgrep -x gnome-shell -l
else
    echo "✗ GNOME Shell is not running"
fi
echo

echo "=== FIREFOX STATUS ==="
echo "Firefox processes:"
pgrep firefox -l || echo "No Firefox processes found"
echo
echo "Firefox for kiosk user:"
pgrep -u kiosk firefox -l || echo "No Firefox processes for kiosk user"
echo

echo "=== CONFIGURATION FILES ==="
echo "GDM configuration:"
if [ -f /etc/gdm/custom.conf ]; then
    echo "✓ GDM custom config exists"
    cat /etc/gdm/custom.conf
else
    echo "✗ GDM custom config missing"
fi
echo
echo "Kiosk home directory:"
ls -la /var/home/kiosk/ 2>/dev/null || echo "Kiosk home directory not found"
echo
echo "Autostart files:"
ls -la /var/home/kiosk/.config/autostart/ 2>/dev/null || echo "Autostart directory not found"
echo
echo "Firefox profile:"
ls -la /var/home/kiosk/.mozilla/firefox/ 2>/dev/null || echo "Firefox profile directory not found"
echo

echo "=== LOG FILES ==="
echo "Recent kiosk manager logs:"
if [ -f /var/log/kiosk-manager.log ]; then
    echo "✓ Kiosk manager log exists"
    echo "Last 20 lines:"
    tail -20 /var/log/kiosk-manager.log
else
    echo "✗ Kiosk manager log not found"
fi
echo
echo "Recent kiosk session logs:"
if [ -f /var/log/kiosk-session.log ]; then
    echo "✓ Kiosk session log exists"
    echo "Last 20 lines:"
    tail -20 /var/log/kiosk-session.log
else
    echo "✗ Kiosk session log not found"
fi
echo
echo "Recent GDM logs:"
journalctl -u gdm --since "10 minutes ago" --no-pager -n 10
echo
echo "Recent Firefox watchdog logs:"
journalctl -u firefox-watchdog.timer --since "10 minutes ago" --no-pager -n 5
echo
echo "Recent kiosk-manager service logs:"
journalctl -u kiosk-manager.service --since "10 minutes ago" --no-pager -n 10
echo

echo "=== SYSTEM INFORMATION ==="
echo "Operating system:"
cat /etc/os-release | grep -E "(NAME|VERSION)"
echo
echo "Systemd version:"
systemctl --version | head -1
echo
echo "Available memory:"
free -h
echo
echo "Disk usage:"
df -h /
echo

echo "=== NETWORK STATUS ==="
echo "Network interfaces:"
ip addr show | grep -E "(inet |UP|DOWN)" | head -10
echo
echo "DNS resolution test:"
nslookup google.com 2>/dev/null | head -5 || echo "DNS resolution failed"
echo

echo "=== RECOMMENDED ACTIONS ==="
echo "To manually restart the kiosk system:"
echo "1. systemctl restart kiosk-manager.service"
echo "2. systemctl restart gdm"
echo "3. loginctl terminate-user kiosk  # Force re-login"
echo
echo "To enable Firefox user service:"
echo "sudo -u kiosk systemctl --user enable firefox-kiosk.service"
echo
echo "To manually start Firefox:"
echo "su - kiosk -c 'DISPLAY=:0 XDG_RUNTIME_DIR=/run/user/1001 /usr/local/bin/firefox-kiosk.sh &'"
echo

echo "=== DIAGNOSTIC COMPLETE ==="
echo "Run this script as root for complete information"
echo "Timestamp: $(date)"
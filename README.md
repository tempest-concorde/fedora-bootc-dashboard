# fedora-bootc-dashboard
Firefox kiosk system using Fedora bootc with automatic shutdown.

## Overview

This project creates a bootc-based system that automatically boots into a Firefox kiosk mode, displaying a specified webpage. The system includes:

- Automatic login to a dedicated kiosk user
- Firefox launched in full-screen kiosk mode
- Configurable target webpage
- Automatic shutdown at 22:00 (10:00 PM) daily
- Optimized for minimal user interaction

## Features

- **Dual-Tab Kiosk Mode**: Firefox runs in full-screen mode displaying two tabs
- **Auto-login with Re-login**: System automatically logs into kiosk user and re-logs if logged out
- **Automatic Firefox Restart**: Firefox automatically restarts if closed or crashes
- **Configurable URLs**: Set both webpages to display via environment variables
- **Scheduled Shutdown**: Automatically powers off at 22:00 each day
- **Security**: Disabled downloads, extensions, and developer tools
- **Performance**: Optimized Firefox settings for kiosk displays

## Configuration

### Setting the Kiosk URLs

The kiosk displays two tabs by default:
- **Tab 1**: https://www.redhat.com
- **Tab 2**: https://fedoraproject.org

To customize the URLs, set the environment variables during build or runtime:

```shell
export KIOSK_URL_1=https://your-first-webpage.com
export KIOSK_URL_2=https://your-second-webpage.com
```

For backward compatibility, `KIOSK_URL` is also supported and will override the first tab:

```shell
export KIOSK_URL=https://your-webpage.com  # Sets first tab
export KIOSK_URL_2=https://your-second-webpage.com  # Sets second tab
```

### Build Environment Setup

```shell
export SSH_KEY_PATH=$HOME/.ssh/id_rsa.pub
export DOCKER_AUTH_PATH=`pwd`/docker-auth.json # for your container registry
```

**Note**: Administration is performed via root SSH access only. No additional admin user is created.

## Building

### Create ISO Image
```shell
make iso
```

### Create QCOW2 Image
```shell
make qcow
```

Using `direnv` or similar to manage the secrets is encouraged.

## System Behavior

1. **Install**: Kickstart creates kiosk user and configures auto-login during installation
2. **Boot**: System boots and automatically logs into the `kiosk` user
3. **Re-Login**: If user logs out, system automatically re-logs into kiosk user after 5 seconds
4. **Launch**: Firefox automatically starts in kiosk mode showing two configured webpages in tabs
5. **Display**: Full-screen display with tab bar visible for easy navigation between content
6. **Restart**: Firefox automatically restarts if it crashes or is closed
7. **Shutdown**: System automatically powers off at 22:00 daily

## User Accounts

### Kiosk User
- **Username**: `kiosk`
- **Home Directory**: `/var/home/kiosk` (bootc standard)
- **Auto-login**: Enabled via GDM configuration
- **Desktop**: GNOME with Firefox auto-start
- **Permissions**: Standard user with no sudo access

### Administrative Access
- **Method**: Root SSH access only
- **SSH Key**: Configured during build with `SSH_KEY_PATH`
- **No Admin User**: No additional admin user is created
- **Root Login**: SSH key-based authentication for root user

## Systemd Services

- `shutdown-timer.timer`: Daily timer that triggers shutdown at 22:00
- `shutdown-timer.service`: Service that executes system poweroff
- `gdm.service`: Display manager with auto-login and re-login configured
- `chronyd.service`: Time synchronization using chrony NTP client
- `firefox-kiosk.service`: User service for automatic Firefox startup with restart capability
- `firefox-watchdog.timer`: Monitors and restarts Firefox if needed
- `sshd.service`: SSH daemon for root administrative access

## Firefox Configuration

The kiosk Firefox instance includes:
- Disabled updates and notifications
- No toolbars or bookmarks visible (tabs remain visible for navigation)
- Disabled right-click context menu
- Disabled developer tools
- Optimized performance settings
- Disabled downloads and extensions
- Two-tab configuration with controlled navigation

## Bootc-Specific Features

- **Home Directories**: Uses `/var/home/` as per bootc standards (mutable after first boot)
- **Kickstart Setup**: User creation and initial configuration handled during installation
- **Disk Wiping**: Secure installation with complete disk clearing before setup
- **Immutable Base**: Only configuration files in `/var/home/` are mutable post-deployment
- **Atomic Updates**: System can be updated atomically via bootc

## Notes

1. **Administration**: Only root SSH access is configured - no admin user is created
2. **SSH Access**: Ensure your SSH public key is properly set in `SSH_KEY_PATH` before building
3. Root users don't cache credentials for podman in RHEL. Rebooting will require re-authenticating with `quay.io` and `registry.redhat.io`
4. Don't try to add more than one group to a user using `--groups`
5. It's much easier if you build as root and don't use sudo
6. The shutdown timer uses the system clock - ensure proper timezone configuration
7. User configurations in `/var/home/kiosk/` persist across bootc updates
8. Kickstart handles initial system setup including user creation and configuration
9. Time synchronization is handled by chrony (chronyd service) which is ideal for systems that may be intermittently connected

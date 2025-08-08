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

- **Kiosk Mode**: Firefox runs in full-screen mode with minimal UI
- **Auto-login**: System automatically logs into the kiosk user account
- **Configurable URL**: Set the webpage to display via environment variable
- **Scheduled Shutdown**: Automatically powers off at 22:00 each day
- **Security**: Disabled downloads, extensions, and developer tools
- **Performance**: Optimized Firefox settings for kiosk displays

## Configuration

### Setting the Kiosk URL

The default webpage is https://www.redhat.com. To change this, set the `KIOSK_URL` environment variable during build or runtime:

```shell
export KIOSK_URL=https://your-webpage.com
```

### Build Environment Setup

```shell
export SSH_KEY_PATH=$HOME/.ssh/id_rsa.pub
export DOCKER_AUTH_PATH=`pwd`/docker-auth.json # for your container registry
export PASSWORD_HASH='' # use openssl passwd -6 - use raw strings (single quotes)
export USERNAME=myusername
```

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
3. **Launch**: Firefox automatically starts in kiosk mode showing the configured webpage
4. **Display**: Full-screen display with minimal browser UI
5. **Shutdown**: System automatically powers off at 22:00 daily

## Kiosk User Account

- **Username**: `kiosk`
- **Home Directory**: `/var/home/kiosk` (bootc standard)
- **Auto-login**: Enabled via GDM configuration
- **Desktop**: GNOME with Firefox auto-start
- **Permissions**: Standard user with no sudo access

## Systemd Services

- `shutdown-timer.timer`: Daily timer that triggers shutdown at 22:00
- `shutdown-timer.service`: Service that executes system poweroff
- `gdm.service`: Display manager with auto-login configured
- `chronyd.service`: Time synchronization using chrony NTP client

## Firefox Configuration

The kiosk Firefox instance includes:
- Disabled updates and notifications
- No toolbars or bookmarks visible
- Disabled right-click context menu
- Disabled developer tools
- Optimized performance settings
- Disabled downloads and extensions

## Bootc-Specific Features

- **Home Directories**: Uses `/var/home/` as per bootc standards (mutable after first boot)
- **Kickstart Setup**: User creation and initial configuration handled during installation
- **Immutable Base**: Only configuration files in `/var/home/` are mutable post-deployment
- **Atomic Updates**: System can be updated atomically via bootc

## Notes

1. Root users don't cache credentials for podman in RHEL. Rebooting will require re-authenticating with `quay.io` and `registry.redhat.io`
2. Don't try to add more than one group to a user using `--groups`
3. It's much easier if you build as root and don't use sudo
4. The shutdown timer uses the system clock - ensure proper timezone configuration
5. User configurations in `/var/home/kiosk/` persist across bootc updates
6. Kickstart handles initial system setup including user creation and configuration
7. Time synchronization is handled by chrony (chronyd service) which is ideal for systems that may be intermittently connected

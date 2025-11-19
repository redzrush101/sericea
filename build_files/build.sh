#!/bin/bash

set -ouex pipefail

# ============================================================================
# 1. REMOVE FIREFOX (Build-Side)
# ============================================================================
echo "Removing Firefox..."
# We use dnf5 because we are modifying the base image source, not 
# overriding a running deployment.
dnf5 remove -y firefox firefox-langpacks

# ============================================================================
# 2. INSTALL RPM PACKAGES & GROUPS
# ============================================================================
echo "Installing RPMs and Groups..."
dnf5 group install -y --with-optional virtualization
dnf5 group install -y --with-optional development-tools
dnf5 install -y neovim distrobox

# ============================================================================
# 3. SWAP FLATPAK (EXPERIMENTAL PREINSTALL FEATURE)
# ============================================================================
echo "Swapping to Experimental Flatpak (ublue-os/flatpak-test)..."
dnf5 -y copr enable ublue-os/flatpak-test
dnf5 -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak flatpak
dnf5 -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak-libs flatpak-libs
dnf5 -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak-session-helper flatpak-session-helper

# Sanity Check
rpm -q flatpak --qf "%{NAME} %{VENDOR}\n" | grep -q ublue-os || { echo "Flatpak not from our copr, aborting"; exit 1; }

# ============================================================================
# 4. ENABLE SERVICES
# ============================================================================
echo "Enabling Services..."

# 1. Flatpak Preinstall Service (Provided by the experimental RPM)
#    This reads your .preinstall file and installs apps on boot.
systemctl enable flatpak-preinstall.service

# 2. Gigabyte BIOS Fix (Provided by your system_files COPY)
systemctl enable gigabyte-wake-fix.service

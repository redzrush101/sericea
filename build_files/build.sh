#!/bin/bash

set -ouex pipefail

# ============================================================================
# 1. REMOVE FIREFOX (Build-Side)
# ============================================================================
echo "Removing Firefox..."
dnf5 remove -y firefox firefox-langpacks

# ============================================================================
# 2. INSTALL RPM PACKAGES & GROUPS
# ============================================================================
echo "Installing RPMs and Groups..."
dnf5 group install -y --with-optional virtualization
dnf5 group install -y --with-optional development-tools
dnf5 install -y neovim distrobox

# ============================================================================
# 3. ENABLE SERVICES
# ============================================================================
echo "Enabling Services..."
# 1 Gigabyte BIOS Fix (Provided by your system_files COPY)
systemctl enable gigabyte-wake-fix.service

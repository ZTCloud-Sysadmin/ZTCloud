#!/bin/bash
set -e

# --- Import logging ---
source /opt/ZTCloud/scripts/log.sh

log "[INFO] Starting system initialization..."

# Update package lists
log "[INFO] Running apt update..."
apt update

# Install required base packages (NO wget, git now included)
log "[INFO] Installing required base packages..."
apt install -y curl unzip ca-certificates lsb-release gnupg software-properties-common git

# Confirm installation
log "[INFO] Installed packages:"
dpkg -l curl unzip ca-certificates lsb-release gnupg software-properties-common git | tee -a "$LOG_FILE"

log "[INFO] System initialization complete."

#!/bin/bash
set -e

# --- Import logging dynamically ---
if [[ -z "$ZT_INSTALLER_DIR" ]]; then
  ZT_INSTALLER_DIR="/opt/ZTCloud/installer"
fi

source "$ZT_INSTALLER_DIR/scripts/log.sh"

log "[INFO] Starting system initialization..."

# --- Minimal install of required packages ---
log "[INFO] Checking if Git, curl, and required packages are installed..."
apt update
apt install -y git curl ca-certificates lsb-release gnupg software-properties-common unzip

log "[INFO] Minimal required packages installed."

# Confirm installation
log "[INFO] Installed minimal packages overview:"
dpkg -l git curl ca-certificates lsb-release gnupg software-properties-common unzip | tee -a "$ZT_LOG_FILE"

log "[INFO] System initialization complete."

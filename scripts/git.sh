#!/bin/bash
set -e

# --- Import logging dynamically ---
if [[ -z "$ZT_INSTALLER_DIR" ]]; then
  ZT_INSTALLER_DIR="/opt/ZTCloud/installer"
fi

source "$ZT_INSTALLER_DIR/scripts/log.sh"

INSTALL_DIR="$ZT_INSTALLER_DIR"
SCRIPTS_DIR="$INSTALL_DIR/scripts"

log "[INFO] Preparing to clone ZTCloud installer repository..."

# Clone or pull repo
if [[ ! -d "$INSTALL_DIR/.git" ]]; then
  log "[INFO] Cloning repository into $INSTALL_DIR..."
  git clone --depth 1 --branch main https://github.com/ZTCloud-Sysadmin/ZTCloud.git "$INSTALL_DIR"
  log "[INFO] Clone completed successfully."
else
  log "[INFO] Installer repo already exists. Pulling latest changes..."
  git -C "$INSTALL_DIR" pull
  log "[INFO] Pull completed successfully."
fi

# --- Ensure scripts are executable ---
log "[INFO] Fixing permissions for all $SCRIPTS_DIR/*.sh files..."
chmod +x "$SCRIPTS_DIR"/*.sh || true

log "[INFO] Scripts made executable."

log "[INFO] Git repository ready."

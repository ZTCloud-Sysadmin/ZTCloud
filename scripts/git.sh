#!/bin/bash
set -e

# --- Import logging ---
source /opt/ZTCloud/installer/scripts/log.sh

# --- Variables ---
INSTALL_DIR="/opt/ZTCloud/installer"
SCRIPTS_DIR="$INSTALL_DIR/scripts"
REPO_URL="https://github.com/ZTCloud-Sysadmin/ZTCloud.git"
REPO_BRANCH="main"

log "[INFO] Preparing to clone ZTCloud installer repository..."

# Clone or pull repo
if [[ ! -d "$INSTALL_DIR/.git" ]]; then
  log "[INFO] Cloning repository into $INSTALL_DIR..."
  git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$INSTALL_DIR"
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

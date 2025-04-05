#!/bin/bash
set -e

# --- Define base paths ---
ZT_BASE_DIR="/opt/ZTCloud"
ZT_INSTALLER_DIR="$ZT_BASE_DIR/installer"
ZT_SCRIPTS_DIR="$ZT_INSTALLER_DIR/scripts"
ZT_LOG_DIR="/opt/log/installer"
ZT_LOG_FILE="$ZT_LOG_DIR/ztcloud-install.log"

mkdir -p "$ZT_LOG_DIR"
touch "$ZT_LOG_FILE"

timestamp() {
  date "+%Y-%m-%d %H:%M:%S"
}

log() {
  echo "[$(timestamp)] $1" | tee -a "$ZT_LOG_FILE"
}

log "ZTCloud new installer started."

# --- Clone Git Repo ---
if [[ -f "$ZT_SCRIPTS_DIR/git.sh" ]]; then
  log "[INFO] Running git.sh to clone repository..."
  ZT_INSTALLER_DIR="$ZT_INSTALLER_DIR" bash "$ZT_SCRIPTS_DIR/git.sh"
else
  log "[WARN] $ZT_SCRIPTS_DIR/git.sh not found. Skipping repository clone."
fi

# --- Make all scripts executable ---
log "[INFO] Making all $ZT_SCRIPTS_DIR/*.sh executable..."
chmod +x "$ZT_SCRIPTS_DIR"/*.sh || true

# --- Run modular scripts after repo is cloned ---

# Run NTP sync
if [[ -f "$ZT_SCRIPTS_DIR/ntp.sh" ]]; then
  log "[INFO] Running NTP sync (ntp.sh)..."
  ZT_INSTALLER_DIR="$ZT_INSTALLER_DIR" bash "$ZT_SCRIPTS_DIR/ntp.sh"
else
  log "[WARN] $ZT_SCRIPTS_DIR/ntp.sh not found!"
fi

# Run System Init (base packages)
if [[ -f "$ZT_SCRIPTS_DIR/init.sh" ]]; then
  log "[INFO] Running system initialization (init.sh)..."
  ZT_INSTALLER_DIR="$ZT_INSTALLER_DIR" bash "$ZT_SCRIPTS_DIR/init.sh"
else
  log "[WARN] $ZT_SCRIPTS_DIR/init.sh not found!"
fi

log "ZTCloud install.sh completed."

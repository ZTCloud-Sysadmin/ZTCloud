#!/bin/bash
set -e

# --- Basic logging setup inside install.sh ---
LOG_DIR="/opt/log/installer"
LOG_FILE="$LOG_DIR/ztcloud-install.log"

mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

timestamp() {
  date "+%Y-%m-%d %H:%M:%S"
}

log() {
  echo "[$(timestamp)] $1" | tee -a "$LOG_FILE"
}

# --- Begin install ---
log "ZTCloud new installer started."

# --- Run NTP Sync ---
if [[ -f "/opt/ZTCloud/scripts/ntp.sh" ]]; then
  log "[INFO] Found ntp.sh. Running NTP synchronization..."
  bash /opt/ZTCloud/scripts/ntp.sh
else
  log "[WARN] /opt/ZTCloud/scripts/ntp.sh not found. Skipping NTP sync."
fi

# --- Run System Initialization ---
if [[ -f "/opt/ZTCloud/scripts/init.sh" ]]; then
  log "[INFO] Found init.sh. Running system initialization..."
  bash /opt/ZTCloud/scripts/init.sh
else
  log "[WARN] /opt/ZTCloud/scripts/init.sh not found. Skipping base system setup."
fi

# --- Clone the repository using git.sh ---
if [[ -f "/opt/ZTCloud/scripts/git.sh" ]]; then
  log "[INFO] Found git.sh. Cloning the repository..."
  bash /opt/ZTCloud/scripts/git.sh
else
  log "[WARN] /opt/ZTCloud/scripts/git.sh not found. Cannot clone repository."
fi

log "ZTCloud install.sh finished."

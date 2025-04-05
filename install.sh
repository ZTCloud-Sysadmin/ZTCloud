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

log "ZTCloud new installer started."

# --- Minimal install of required packages ---
log "[INFO] Checking if Git and curl are installed..."
apt update
apt install -y git curl ca-certificates lsb-release gnupg software-properties-common unzip

log "[INFO] Git and curl installed."

# --- Clone the full repo immediately ---
INSTALLER_BASE="/opt/ZTCloud/installer"
SCRIPTS_DIR="$INSTALLER_BASE/scripts"
REPO_URL="https://github.com/ZTCloud-Sysadmin/ZTCloud.git"
REPO_BRANCH="main"

if [[ ! -d "$INSTALLER_BASE/.git" ]]; then
  log "[INFO] Cloning repository into $INSTALLER_BASE..."
  git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$INSTALLER_BASE"
  log "[INFO] Clone completed."
else
  log "[INFO] Repository already exists. Pulling latest changes..."
  git -C "$INSTALLER_BASE" pull
  log "[INFO] Pull completed."
fi

# --- Make sure scripts are executable ---
log "[INFO] Making all $SCRIPTS_DIR/*.sh executable..."
chmod +x "$SCRIPTS_DIR"/*.sh || true

# --- Now run modular scripts ---

# Run NTP sync
if [[ -f "$SCRIPTS_DIR/ntp.sh" ]]; then
  log "[INFO] Running NTP sync (ntp.sh)..."
  bash "$SCRIPTS_DIR/ntp.sh"
else
  log "[WARN] $SCRIPTS_DIR/ntp.sh not found after clone!"
fi

# Run system init
if [[ -f "$SCRIPTS_DIR/init.sh" ]]; then
  log "[INFO] Running base system setup (init.sh)..."
  bash "$SCRIPTS_DIR/init.sh"
else
  log "[WARN] $SCRIPTS_DIR/init.sh not found after clone!"
fi

# (Later: Call other modular scripts here)

log "ZTCloud install.sh completed."

#!/bin/bash
set -e

# --- Basic logging setup directly inside install.sh ---
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

# --- Minimal initial setup: ensure Git and curl exist ---
log "[INFO] Checking if Git and curl are installed..."
apt update

apt install -y git curl ca-certificates lsb-release gnupg software-properties-common unzip

log "[INFO] Git and curl installed."

# --- Clone the full repo immediately ---
INSTALL_DIR="/opt/ZTCloud/installer"
REPO_URL="https://github.com/ZTCloud-Sysadmin/ZTCloud.git"
REPO_BRANCH="main"

if [[ ! -d "$INSTALL_DIR/.git" ]]; then
  log "[INFO] Cloning repository into $INSTALL_DIR..."
  git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$INSTALL_DIR"
  log "[INFO] Clone completed."
else
  log "[INFO] Repository already exists. Pulling latest changes..."
  git -C "$INSTALL_DIR" pull
  log "[INFO] Pull completed."
fi

# --- Make sure scripts are executable ---
log "[INFO] Making all /scripts/*.sh executable..."
chmod +x /opt/ZTCloud/scripts/*.sh || true

# --- Now start modular install ---

# Run NTP sync
if [[ -f "/opt/ZTCloud/scripts/ntp.sh" ]]; then
  log "[INFO] Running NTP sync (ntp.sh)..."
  bash /opt/ZTCloud/scripts/ntp.sh
else
  log "[WARN] /opt/ZTCloud/scripts/ntp.sh not found after clone!"
fi

# Run system init
if [[ -f "/opt/ZTCloud/scripts/init.sh" ]]; then
  log "[INFO] Running base system setup (init.sh)..."
  bash /opt/ZTCloud/scripts/init.sh
else
  log "[WARN] /opt/ZTCloud/scripts/init.sh not found after clone!"
fi

# Clone repo again if needed (later)

log "ZTCloud install.sh completed."

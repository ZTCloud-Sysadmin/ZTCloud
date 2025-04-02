#!/bin/bash
set -e

REPO_URL="https://github.com/ZTCloud-Sysadmin/ZTCloud.git"
REPO_BRANCH="main"
INSTALL_DIR="/opt/ZTCloud/installer"
LOG_DIR="/opt/log/installer"
LOG_FILE="$LOG_DIR/ztcloud-bootstrap.log"
ACTION="$1"
DRY_RUN=false

timestamp() {
  date "+%Y-%m-%d %H:%M:%S"
}

log() {
  echo "[$(timestamp)] $1" | tee -a "$LOG_FILE"
}

ntp_sync_check() {
  log "[INFO] Verifying NTP synchronization..."
  for i in {1..10}; do
    if timedatectl status | grep -q 'NTP synchronized: yes'; then
      log "[INFO] NTP is synchronized. Current system time: $(date)"
      return
    fi
    sleep 1
  done
  log "[WARN] NTP is still not synchronized. System time may be off: $(date)"
  log "[INFO] Consider running: timedatectl set-ntp true && timedatectl status"
}

# --- Setup log directory ---
mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

log "ZTCloud bootstrap started."

# --- Argument parsing ---
if [[ "$ACTION" == "--dry-run" ]]; then
  DRY_RUN=true
  ACTION="$2"
fi

if [[ -z "$ACTION" ]]; then
  log "[ERROR] Usage: $0 [--dry-run] [--init | --deploy]"
  exit 1
fi

# --- Check and auto-fix system clock if skewed ---
log "[INFO] Checking system clock accuracy..."

CURRENT_EPOCH=$(date +%s)
THRESHOLD_EPOCH=$(date --date="2025-03-30" +%s)

if (( CURRENT_EPOCH > THRESHOLD_EPOCH + 86400 || CURRENT_EPOCH < THRESHOLD_EPOCH - 86400 )); then
  log "[WARN] System clock appears to be off (current: $(date))"
  log "[INFO] Attempting to auto-correct with timedatectl..."

  if timedatectl set-ntp true 2>/dev/null; then
    log "[INFO] NTP enabled via timedatectl. Waiting for sync..."
    sleep 5
    log "[INFO] New system time: $(date)"
  else
    log "[ERROR] Failed to enable NTP with timedatectl. Please set time manually:"
    log "        timedatectl set-time 'YYYY-MM-DD HH:MM:SS'"
  fi
else
  log "[INFO] System clock appears to be within acceptable range: $(date)"
fi

ntp_sync_check

# --- Ensure git is available ---
if ! command -v git &>/dev/null; then
  log "[INFO] Git not found. Installing minimal git support..."
  apt update && apt install -y git >> "$LOG_FILE" 2>&1
else
  log "[INFO] Git is already installed."
fi

# --- Dry-run info ---
if $DRY_RUN; then
  log "[DRY-RUN] Would clone repo to: $INSTALL_DIR"
  log "[DRY-RUN] Would checkout branch: $REPO_BRANCH"
  log "[DRY-RUN] Would run: install.sh $ACTION"
  log "ZTCloud bootstrap dry-run complete."
  exit 0
fi

# --- Clone or pull repo ---
if [[ ! -d "$INSTALL_DIR/.git" ]]; then
  log "[INFO] Cloning ZTCloud installer from $REPO_URL into $INSTALL_DIR..."
  git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$INSTALL_DIR" >> "$LOG_FILE" 2>&1
else
  log "[INFO] Installer already exists. Pulling latest updates..."
  git -C "$INSTALL_DIR" pull >> "$LOG_FILE" 2>&1
fi

# --- Run main installer ---
cd "$INSTALL_DIR/Installer"

if [[ ! -x "./install.sh" ]]; then
  log "[WARN] install.sh is not executable."
  log "[INFO] Attempting to auto-fix permissions for all .sh scripts..."
  
  find . -type f -name "*.sh" -exec chmod +x {} \;

  if [[ ! -x "./install.sh" ]]; then
    log "[ERROR] Failed to fix permissions. Please run manually:"
    log "        chmod +x $INSTALL_DIR/Installer/*.sh"
    log "        chmod +x $INSTALL_DIR/Installer/*/*.sh"
    exit 1
  else
    log "[INFO] Permissions fixed successfully."
  fi
fi

log "[INFO] Running installer: install.sh $ACTION"
./install.sh "$ACTION" | tee -a "$LOG_FILE"

log "ZTCloud bootstrap completed."

# --- Final NTP status check ---
ntp_sync_check

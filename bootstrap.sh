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
log "[INFO] Running installer: install.sh $ACTION"
cd "$INSTALL_DIR/Installer"
./install.sh "$ACTION" | tee -a "$LOG_FILE"

log "ZTCloud bootstrap completed."

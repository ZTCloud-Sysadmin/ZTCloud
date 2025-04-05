#!/bin/bash
set -e

REPO_URL="https://github.com/ZTCloud-Sysadmin/ZTCloud.git"
REPO_BRANCH="main"
INSTALL_DIR="/opt/ZTCloud/installer"
LOG_DIR="/opt/log/installer"
LOG_FILE="$LOG_DIR/ztcloud-bootstrap.log"
ACTION="$1"
DRY_RUN=false
FORCE_CLOCK_RESET=false
FORCE_UTC=true  # Default: Force UTC unless --no-utc is used

timestamp() {
  date "+%Y-%m-%d %H:%M:%S"
}

log() {
  echo "[$(timestamp)] $1" | tee -a "$LOG_FILE"
}

ntp_sync_check() {
  log "[INFO] Verifying NTP synchronization..."
  
  local attempts=0
  local max_attempts=3

  while (( attempts < max_attempts )); do
    if timedatectl show | grep -q 'SystemClockSynchronized=yes'; then
      log "[INFO] NTP is synchronized. Current system time: $(date)"
      return 0
    fi
    log "[WARN] NTP not yet synchronized. Waiting 10 seconds (attempt $((attempts + 1))/$max_attempts)..."
    sleep 10
    ((attempts++))
  done

  log "[ERROR] NTP synchronization failed after $((max_attempts * 10)) seconds. Attempting manual fallback sync using ntpdate..."

  if command -v ntpdate &>/dev/null; then
    ntpdate -u pool.ntp.org && log "[INFO] Manual fallback NTP sync successful." && return 0
  else
    log "[WARN] ntpdate not installed, installing now..."
    apt-get update && apt-get install -y ntpdate
    ntpdate -u pool.ntp.org && log "[INFO] Manual fallback NTP sync successful." && return 0
  fi

  if timedatectl show | grep -q 'SystemClockSynchronized=yes'; then
    log "[INFO] System clock synchronized after manual fallback."
    return 0
  fi

  log "[FATAL] NTP synchronization completely failed. Aborting install to prevent clock errors."
  exit 1
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

if [[ "$ACTION" == "--force-clock-reset" ]]; then
  FORCE_CLOCK_RESET=true
  ACTION="$2"
elif [[ "$ACTION" == "--dry-run" && "$2" == "--force-clock-reset" ]]; then
  DRY_RUN=true
  FORCE_CLOCK_RESET=true
  ACTION="$3"
fi

if [[ "$ACTION" == "--no-utc" ]]; then
  FORCE_UTC=false
  ACTION="$2"
elif [[ "$ACTION" == "--dry-run" && "$2" == "--no-utc" ]]; then
  DRY_RUN=true
  FORCE_UTC=false
  ACTION="$3"
fi

if [[ -z "$ACTION" ]]; then
  log "[ERROR] Usage: $0 [--dry-run] [--force-clock-reset] [--no-utc] [--init | --deploy]"
  exit 1
fi

# --- Bootstrap Summary ---
log "---------------------------------"
log "ZTCloud Bootstrap Configuration:"
log " Timezone enforcement: $(if $FORCE_UTC; then echo 'UTC'; else echo 'System default'; fi)"
log " Clock reset: $(if $FORCE_CLOCK_RESET; then echo 'enabled'; else echo 'disabled'; fi)"
log " Dry-run mode: $(if $DRY_RUN; then echo 'enabled'; else echo 'disabled'; fi)"
log " Action: $ACTION"
log "---------------------------------"

# --- Optional force UTC timezone ---
if $FORCE_UTC; then
  log "[INFO] Forcing timezone to UTC..."
  timedatectl set-timezone UTC
  log "[INFO] Timezone is now set to: $(timedatectl show -p Timezone --value)"
else
  log "[INFO] Skipping timezone change. System timezone remains: $(timedatectl show -p Timezone --value)"
fi

# --- Optional forced clock reset ---
if $FORCE_CLOCK_RESET; then
  log "[INFO] --force-clock-reset enabled. Forcing time to: 2025-03-30 12:00:00"
  timedatectl set-time "2025-03-30 12:00:00"
  log "[INFO] Time forcibly reset. Current system time: $(date)"
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

# --- First NTP sync check ---
ntp_sync_check

# --- Clone or pull repo ---
if [[ ! -d "$INSTALL_DIR/.git" ]]; then
  log "[INFO] Cloning ZTCloud installer from $REPO_URL into $INSTALL_DIR..."
  git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$INSTALL_DIR" >> "$LOG_FILE" 2>&1
else
  log "[INFO] Installer already exists. Pulling latest updates..."
  git -C "$INSTALL_DIR" pull >> "$LOG_FILE" 2>&1
fi

# --- Second NTP sync verification ---
ntp_sync_check

# --- Ensure git is available ---
if ! command -v git &>/dev/null; then
  log "[INFO] Git not found. Installing minimal git support..."
  apt update && apt install -y git >> "$LOG_FILE" 2>&1
else
  log "[INFO] Git is already installed."
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

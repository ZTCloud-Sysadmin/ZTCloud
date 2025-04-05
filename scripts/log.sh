#!/bin/bash
set -e

# --- Setup reusable logging module ---
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

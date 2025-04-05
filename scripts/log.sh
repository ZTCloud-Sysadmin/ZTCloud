#!/bin/bash
set -e

# --- Setup reusable logging module ---

# Use passed variable or fallback
if [[ -z "$ZT_LOG_DIR" ]]; then
  ZT_LOG_DIR="/opt/log/installer"
fi

ZT_LOG_FILE="$ZT_LOG_DIR/ztcloud-install.log"

mkdir -p "$ZT_LOG_DIR"
touch "$ZT_LOG_FILE"

timestamp() {
  date "+%Y-%m-%d %H:%M:%S"
}

log() {
  echo "[$(timestamp)] $1" | tee -a "$ZT_LOG_FILE"
}

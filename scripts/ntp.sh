#!/bin/bash
set -e

# --- Import logging ---
source /opt/ZTCloud/scripts/log.sh

log "[INFO] Starting NTP synchronization..."

timedatectl set-ntp true
log "[INFO] NTP enabled. Waiting 30 seconds for sync..."
sleep 30

if timedatectl show | grep -q 'SystemClockSynchronized=yes'; then
  log "[INFO] NTP synchronized successfully. Current time: $(date)"
  exit 0
fi

log "[WARN] NTP not yet synchronized after 30 seconds. Attempting manual fallback..."

if ! command -v ntpdate &>/dev/null; then
  log "[WARN] ntpdate not found. Installing..."
  apt update && apt install -y ntpdate
fi

if ntpdate -u pool.ntp.org; then
  log "[INFO] Manual fallback NTP sync completed."
else
  log "[ERROR] Manual NTP fallback failed."
  exit 1
fi

if timedatectl show | grep -q 'SystemClockSynchronized=yes'; then
  log "[INFO] System clock synchronized after fallback. Current time: $(date)"
else
  log "[FATAL] NTP synchronization failed after fallback. Aborting."
  exit 1
fi

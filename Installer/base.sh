#!/bin/bash

# Logging functions
log_info() {
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo -e "\e[32m[$timestamp] [INFO]\e[0m $1"
  echo "[$timestamp] [INFO] $1" >> "$LOGFILE"
}

log_error() {
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo -e "\e[31m[$timestamp] [ERROR]\e[0m $1" >&2
  echo "[$timestamp] [ERROR] $1" >> "$LOGFILE"
}

# Source installer parts
source "$(dirname "$0")/base/default.sh"
source "$(dirname "$0")/base/docker.sh"

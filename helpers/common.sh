#!/bin/bash

# ============================================================
# ZTCloud Common Functions
# Location: /opt/ztcloud/helpers/common.sh
# ============================================================

# ------------------------------------------------------------
# Colors (only if output is a terminal)
# ------------------------------------------------------------
if [ -t 1 ]; then
    COLOR_RESET="\e[0m"
    COLOR_INFO="\e[32m"   # Green
    COLOR_WARN="\e[33m"   # Yellow
    COLOR_ERROR="\e[31m"  # Red
else
    COLOR_RESET=""
    COLOR_INFO=""
    COLOR_WARN=""
    COLOR_ERROR=""
fi

# ------------------------------------------------------------
# Log Functions
# ------------------------------------------------------------
log_info() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${COLOR_INFO}[INFO]  $timestamp $*${COLOR_RESET}" | tee -a "$LOG_DIR/installer.log"
}

log_warn() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${COLOR_WARN}[WARN]  $timestamp $*${COLOR_RESET}" | tee -a "$LOG_DIR/installer.log"
}

log_error() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${COLOR_ERROR}[ERROR] $timestamp $*${COLOR_RESET}" | tee -a "$LOG_DIR/installer.log"
}

# ------------------------------------------------------------
# Git Repository Synchronization
# ------------------------------------------------------------
sync_git_repo() {
    local repo_dir="$1"

    if [ ! -d "$repo_dir/.git" ]; then
        log_error "No Git repository found in $repo_dir. Cannot sync."
        exit 1
    fi

    cd "$repo_dir" || { log_error "Failed to enter $repo_dir"; exit 1; }

    log_info "Fetching latest changes from origin."
    git fetch origin

    if git show-ref --verify --quiet refs/heads/main; then
        git checkout main
    else
        log_warn "'main' branch does not exist locally. Creating from origin/main."
        git checkout -b main origin/main
    fi

    log_info "Resetting local branch to match origin/main."
    git reset --hard origin/main
}

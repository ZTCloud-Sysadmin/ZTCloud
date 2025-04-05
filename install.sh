#!/bin/bash

# ============================================================
# ZTCloud Installer
# Location: /opt/ztcloud/install.sh
# ============================================================

# ------------------------------------------------------------
# Early minimal logger (before full repo is cloned)
# ------------------------------------------------------------
echo_info() { echo -e "\e[32m[INFO]  $(date '+%Y-%m-%d %H:%M:%S') $*\e[0m"; }
echo_warn() { echo -e "\e[33m[WARN]  $(date '+%Y-%m-%d %H:%M:%S') $*\e[0m"; }
echo_error() { echo -e "\e[31m[ERROR] $(date '+%Y-%m-%d %H:%M:%S') $*\e[0m"; }

# ------------------------------------------------------------
# Configuration (early before loading config.sh)
# ------------------------------------------------------------
BASE_DIR="/opt/ztcloud"
GIT_REPO_URL="https://your-git-repo-url.git"   # <--- CHANGE THIS to your real GitHub repo

# ------------------------------------------------------------
# Step 0: Parse Optional Arguments
# ------------------------------------------------------------
for arg in "$@"; do
    case $arg in
        --dry-run)
            echo_info "Dry-run mode enabled."
            export ENABLE_DRY_RUN=true
            ;;
        *)
            ;;
    esac
done

# ------------------------------------------------------------
# Step 1: Ensure /opt/ztcloud exists
# ------------------------------------------------------------
mkdir -p "$BASE_DIR"

# ------------------------------------------------------------
# Step 2: Ensure git is installed
# ------------------------------------------------------------
if ! command -v git >/dev/null 2>&1; then
    echo_info "git not found. Installing git package..."
    if [ "$ENABLE_DRY_RUN" = "true" ]; then
        echo_info "Dry-run: Would install git. Skipping."
    else
        apt-get update -y && apt-get install -y git
        if [ $? -ne 0 ]; then
            echo_error "Failed to install git. Exiting."
            exit 1
        fi
    fi
else
    echo_info "git already installed."
fi

# ------------------------------------------------------------
# Step 3: Clone repo if missing
# ------------------------------------------------------------
if [ ! -d "$BASE_DIR/.git" ]; then
    echo_info "Cloning ZTCloud repository into $BASE_DIR"
    if [ "$ENABLE_DRY_RUN" = "true" ]; then
        echo_info "Dry-run: Would clone repo from $GIT_REPO_URL. Skipping."
    else
        git clone "$GIT_REPO_URL" "$BASE_DIR"
        if [ $? -ne 0 ]; then
            echo_error "Failed to clone repository. Exiting."
            exit 1
        fi
    fi
else
    echo_info "ZTCloud repository already exists at $BASE_DIR. Checking for updates."
fi

# ------------------------------------------------------------
# Step 4: Load full config and common functions
# ------------------------------------------------------------
source "$BASE_DIR/config/config.sh"
source "$BASE_DIR/scripts/common.sh"

# Make sure log directory exists
mkdir -p "$LOG_DIR"

# ------------------------------------------------------------
# Step 5: Sync Git Repo to origin/main
# ------------------------------------------------------------
if [ "$ENABLE_DRY_RUN" = "true" ]; then
    log_info "Dry-run: Would sync git repo. Skipping git operations."
else
    sync_git_repo "$BASE_DIR"
fi

# ------------------------------------------------------------
# Step 6: Ensure all .sh files are executable
# ------------------------------------------------------------
log_info "Setting executable permissions on installer scripts."
if [ "$ENABLE_DRY_RUN" = "true" ]; then
    log_info "Dry-run: Would chmod +x all .sh files. Skipping."
else
    find "$BASE_DIR" -type f -name "*.sh" -exec chmod +x {} \;
fi

# ------------------------------------------------------------
# Step 7: Install essential base packages (curl, git, sudo)
# ------------------------------------------------------------
if [ "$SKIP_PACKAGE_INSTALL" != "true" ]; then
    install_base_packages
else
    log_info "Skipping base package installation as configured."
fi

# ------------------------------------------------------------
# Step 8: Start Modular Install Process
# ------------------------------------------------------------
log_info "Starting modular installation process."

for script in "$SCRIPT_DIR"/*.sh; do
    [ -f "$script" ] || continue
    log_info "Executing install script: $(basename "$script")"
    
    if [ "$ENABLE_DRY_RUN" = "true" ]; then
        log_info "Dry-run: Would execute $script. Skipping."
    else
        bash "$script"
    fi
done

log_info "ZTCloud installer finished successfully."

# Exit cleanly
exit 0

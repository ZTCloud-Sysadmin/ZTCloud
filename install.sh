#!/bin/bash

# ============================================================
# ZTCloud Installer
# Location: /opt/ztcloud/install.sh
# ============================================================

# ------------------------------------------------------------
# Early Minimal Logger (Before Full Repo is Cloned)
# ------------------------------------------------------------
echo_info() { echo -e "\e[32m[INFO]  $(date '+%Y-%m-%d %H:%M:%S') $*\e[0m"; }
echo_warn() { echo -e "\e[33m[WARN]  $(date '+%Y-%m-%d %H:%M:%S') $*\e[0m"; }
echo_error() { echo -e "\e[31m[ERROR] $(date '+%Y-%m-%d %H:%M:%S') $*\e[0m"; }
echo_info "Starting ZTCloud Installer - Version $INSTALLER_VERSION"

# ------------------------------------------------------------
# Configuration (Early Before Loading config.sh)
# ------------------------------------------------------------
BASE_DIR="/opt/ztcloud"
GIT_REPO_URL="https://github.com/ZTCloud-Sysadmin/ZTCloud.git"   # Update this to your actual GitHub repository URL

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
# Step 1: Ensure $BASE_DIR Exists
# ------------------------------------------------------------
mkdir -p "$BASE_DIR"

# ------------------------------------------------------------
# Step 2: Ensure Git is Installed
# ------------------------------------------------------------
if ! command -v git >/dev/null 2>&1; then
    echo_info "Git not found. Installing git package..."
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
    echo_info "Git is already installed."
fi

# ------------------------------------------------------------
# Step 3: Clone Repo if Missing
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
# Step 4: Load Full Config and Common Functions
# ------------------------------------------------------------
source "$BASE_DIR/config/config.sh"
source "$BASE_DIR/helpers/common.sh"

# Ensure log directory exists
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
# Step 6: Ensure All .sh Files are Executable
# ------------------------------------------------------------
log_info "Setting executable permissions on installer scripts."
if [ "$ENABLE_DRY_RUN" = "true" ]; then
    log_info "Dry-run: Would chmod +x all .sh files. Skipping."
else
    find "$BASE_DIR" -type f -name "*.sh" -exec chmod +x {} \;
fi

# ------------------------------------------------------------
# Step 7: Execute Scripts in INSTALLER_PIPELINE
# ------------------------------------------------------------
log_info "Starting modular installation process."

for script in "${INSTALLER_PIPELINE[@]}"; do
    script_path="$SCRIPT_DIR/$script"
    if [ -f "$script_path" ]; then
        log_info "Executing install script: $script"
        if [ "$ENABLE_DRY_RUN" = "true" ]; then
            log_info "Dry-run: Would execute $script. Skipping."
        else
            bash "$script_path"
            if [ $? -ne 0 ]; then
                log_error "Execution of $script failed. Exiting."
                exit 1
            fi
        fi
    else
        log_warn "Script $script not found in $SCRIPT_DIR. Skipping."
    fi
done

log_info "ZTCloud installer finished successfully."

# Exit cleanly
exit 0

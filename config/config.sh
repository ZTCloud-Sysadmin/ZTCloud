# ============================================================
# ZTCloud Configuration File
# Location: /opt/ztcloud/config/config.sh
# ============================================================
# Installer Version
INSTALLER_VERSION="v1.0.0"

# ------------------------------------------------------------
# Basic Directories
# ------------------------------------------------------------
BASE_DIR="/opt/ztcloud"
SCRIPT_DIR="$BASE_DIR/scripts"
CONFIG_DIR="$BASE_DIR/config"
LOG_DIR="$BASE_DIR/log"

# ------------------------------------------------------------
# Git Repo Settings
# ------------------------------------------------------------
GIT_REPO_URL="https://github.com/ZTCloud-Sysadmin/ZTCloud.git"

# ------------------------------------------------------------
# Base Packages to Install (essential system tools)
# ------------------------------------------------------------
BASE_PACKAGES=(
    "curl"
    "sudo"
    "openssh-client"
)

# ------------------------------------------------------------
# Installer Pipeline
# Define the order of script execution
# ------------------------------------------------------------
INSTALLER_PIPELINE=(
    "packages.sh"
    "system-user.sh"
)

# ------------------------------------------------------------
# Optional Flags
# ------------------------------------------------------------

# Optional User Setup Settings
DISABLE_SSH_PASSWORD_LOGIN=true

# Installer Behavior Flags
SKIP_PACKAGE_INSTALL=false       # true to skip install_base_packages
ENABLE_DRY_RUN=false              # true to simulate installation without making changes
RELOAD_SSHD_AT_END=true           # true to reload sshd safely at the end

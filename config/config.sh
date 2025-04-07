# ============================================================
# ZTCloud Configuration File
# Location: /opt/ztcloud/config/config.sh
# ============================================================
# Installer Version
INSTALLER_VERSION="v1.0.0"

# ------------------------------------------------------------
# System User UID/GID
# ------------------------------------------------------------
ZTCL_SYSADMIN_UID=1099
ZTCL_SYSADMIN_GID=1099

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
  "ca-certificates"
  "gnupg"
  "lsb-release"
  "openssh-client"
)


# ------------------------------------------------------------
# Installer Pipeline
# Define the order of script execution
# ------------------------------------------------------------
INSTALLER_PIPELINE=(
    "packages.sh"
    "system-user.sh"
    "docker.sh"
)

# ------------------------------------------------------------
# Validation Pipeline
# Define the order of validation scripts
# ------------------------------------------------------------
VALIDATION_PIPELINE=(
    "packages-check.sh"       # Always check essential packages first
    "system-user-check.sh"    # Then check if our sysadmin user is properly created
    "sshd-check.sh"            # Then check if SSH access is properly hardened
    "docker-check.sh"          # Finally verify Docker install and settings
)


# ------------------------------------------------------------
# Validation Behavior Flags
# ------------------------------------------------------------
RUN_VALIDATION_AFTER_INSTALL=true     # true = run validation automatically after install


# ------------------------------------------------------------
# Optional Flags
# ------------------------------------------------------------

# Optional User Setup Settings
DISABLE_SSH_PASSWORD_LOGIN=true

# Installer Behavior Flags
SKIP_PACKAGE_INSTALL=false       # true to skip install_base_packages
ENABLE_DRY_RUN=false              # true to simulate installation without making changes
RELOAD_SSHD_AT_END=true           # true to reload sshd safely at the end

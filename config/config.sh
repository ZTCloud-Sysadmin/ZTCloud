#!/bin/bash

# ============================================================
# ZTCloud Configuration File
# Location: /opt/ztcloud/config/config.sh
# ============================================================

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
)

# ------------------------------------------------------------
# Application Install Flags
# (Enable/Disable individual apps here)
# ------------------------------------------------------------
INSTALL_DOCKER=true
INSTALL_TAILSCALE=true
INSTALL_ETCD=false
INSTALL_CADDY=false

# ------------------------------------------------------------
# Optional Flags
# ------------------------------------------------------------
SKIP_PACKAGE_INSTALL=false      # true to skip install_base_packages
ENABLE_DRY_RUN=false             # true to simulate installation without making changes

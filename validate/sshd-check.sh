#!/bin/bash

# ============================================================
# ZTCloud SSHD Validation
# Location: /opt/ztcloud/validate/sshd-check.sh
# ============================================================

source /opt/ztcloud/config/config.sh
source /opt/ztcloud/helpers/common.sh

SSHD_CONFIG_FILE="/etc/ssh/sshd_config"

log_info "Validating SSHD configuration and service status"

# Check if sshd_config exists
if [ ! -f "$SSHD_CONFIG_FILE" ]; then
    log_error "sshd_config not found at $SSHD_CONFIG_FILE ❌"
    exit 1
fi

# Check PasswordAuthentication setting
password_auth_setting=$(grep -i "^PasswordAuthentication" "$SSHD_CONFIG_FILE" | tail -n1 | awk '{print $2}')
if [ "$password_auth_setting" = "no" ]; then
    log_info "PasswordAuthentication is correctly set to no ✅"
else
    log_error "PasswordAuthentication is not disabled! Found: '$password_auth_setting' ❌"
    exit 1
fi

# Validate sshd syntax
if sshd -t >/dev/null 2>&1; then
    log_info "sshd config syntax check passed ✅"
else
    log_error "sshd config syntax check FAILED ❌"
    sshd -t 2>&1 | tee -a "$LOG_DIR/installer.log"
    exit 1
fi

# Check if sshd service is running
if systemctl is-active --quiet sshd; then
    log_info "sshd service is running ✅"
else
    log_error "sshd service is NOT running ❌"
    exit 1
fi

log_info "SSHD validation completed successfully 🎯"

exit 0

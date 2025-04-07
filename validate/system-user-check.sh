#!/bin/bash

# ============================================================
# ZTCloud SSHD Validation
# Location: /opt/ztcloud/validate/sshd-check.sh
# ============================================================

source /opt/ztcloud/config/config.sh
source /opt/ztcloud/helpers/common.sh

log_info "Validating SSHD configuration"

# ------------------------------------------------------------
# Helper: check specific sshd_config parameter
# ------------------------------------------------------------
check_sshd_param() {
    local param="$1"
    local expected="$2"

    # Extract the final active setting from sshd_config
    actual=$(grep -iE "^\s*${param}\s+" /etc/ssh/sshd_config | tail -n 1 | awk '{print tolower($2)}')

    if [ "$actual" == "$expected" ]; then
        log_info "[$param] is correctly set to '$expected' ✅"
    else
        log_error "[$param] expected '$expected', but found '$actual' ❌"
        exit 1
    fi
}

# ------------------------------------------------------------
# Validation Checklist
# ------------------------------------------------------------

# Check if sshd_config exists
if [ ! -f /etc/ssh/sshd_config ]; then
    log_error "/etc/ssh/sshd_config not found ❌"
    exit 1
fi

# Check PasswordAuthentication setting
if [ "$DISABLE_SSH_PASSWORD_LOGIN" = "true" ]; then
    check_sshd_param "PasswordAuthentication" "no"
fi

# Check PubkeyAuthentication is enabled
check_sshd_param "PubkeyAuthentication" "yes"

# Optionally: check PermitRootLogin
check_sshd_param "PermitRootLogin" "no"

# Optional Bonus Check: sshd is running
if systemctl is-active --quiet sshd; then
    log_info "sshd service is running ✅"
else
    log_error "sshd service is NOT running ❌"
    exit 1
fi

log_info "SSHD validation completed successfully 🎯"
exit 0

#!/bin/bash
# ============================================================
# ZTCloud SSHD Configuration Helper
# Location: /opt/ztcloud/helpers/sshd_config.sh
# ============================================================

# Assumes common.sh is already sourced by parent script!

# ------------------------------------------------------------
# Backup and Modify sshd_config safely
# ------------------------------------------------------------

backup_sshd_config() {
    local sshd_config="/etc/ssh/sshd_config"
    local backup_file="/etc/ssh/sshd_config.bak-$(date '+%Y%m%d%H%M%S')"

    if [ -f "$sshd_config" ]; then
        log_info "Backing up $sshd_config to $backup_file"
        cp "$sshd_config" "$backup_file"
    else
        log_warn "No sshd_config found at $sshd_config"
    fi
}

disable_ssh_password_login() {
    local sshd_config="/etc/ssh/sshd_config"

    backup_sshd_config

    # Make sure PasswordAuthentication no is enforced
    if grep -q "^PasswordAuthentication" "$sshd_config"; then
        sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' "$sshd_config"
    else
        echo "PasswordAuthentication no" >> "$sshd_config"
    fi

    log_info "Set PasswordAuthentication to no in $sshd_config"
}
